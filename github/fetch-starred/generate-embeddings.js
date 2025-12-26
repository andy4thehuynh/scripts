require('dotenv').config();
const { Cluster, MutateInSpec } = require('couchbase');
const OpenAI = require('openai');

const CB_CONN = 'couchbase://localhost';
const CB_USER = process.env.CB_USER || 'alh';
const CB_PASSWORD = process.env.CB_PASSWORD;
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

const BUCKET = 'gh-starred';
const SCOPE = 'repos';
const COLLECTION = 'starred';

const openai = new OpenAI({ apiKey: OPENAI_API_KEY });

// text-embedding-3-large = 3000RPM for rate limiting
const BATCH_SIZE = 50; // process 50 at a time
const DELAY_MS = 1000; // 1s between batches

async function connectCouchbase(params) {
  const cluster = await Cluster.connect(CB_CONN, {
    username: CB_USER,
    password: CB_PASSWORD
  });
  const bucket = cluster.bucket(BUCKET);
  const collection = bucket.scope(SCOPE).collection(COLLECTION);

  return { cluster, collection };
}

function combineFieldsForEmbeddings(doc) {
  const parts = [];

  if (doc.name) parts.push(`name: ${doc.name}`);
  if (doc.description) parts.push(`description: ${doc.description}`);
  if (doc.topics && doc.topics.length > 0) {
    parts.push(`topics: ${doc.topics.join(', ')}`);
  }
  if (doc.readme_content) {
    // avoid token limits ( 8191 for text-embedding-3-large) by truncating README
    const maxReadmeChars = 10000;
    const readme = doc.readme_content.substring(0, maxReadmeChars);
    parts.push(`readme: ${readme}`);
  }

  return parts.join('. ');
}

async function generateEmbeddings(text) {
  const response = await openai.embeddings.create({
    model: 'text-embedding-3-large',
    input: text,
    dimensions: 3072
  });

  return response.data[0].embedding;
}

async function processDocuments(params) {
  const { cluster, collection } = await connectCouchbase();

  console.log('Fetching all documents...');

  const query = `
    SELECT META().id, *
    FROM \`${BUCKET}\`.\`${SCOPE}\`.\`${COLLECTION}\`
    WHERE embedding IS MISSING 
  `;

  const result = await cluster.query(query);
  const docs = result.rows;

  console.log(`found ${docs.length} documents without embeddings`);

  // process in batches
  for (let i = 0; i < docs.length; i += BATCH_SIZE) {
    const batch = docs.slice(i, i + BATCH_SIZE);
    console.log(`Processing batch ${Math.floor(i / BATCH_SIZE) + 1}/${Math.ceil(docs.length / BATCH_SIZE)}...`);

    await Promise.all(batch.map(async (row) => {
      try {
        const docId = row.id;
        const doc = row[COLLECTION];

        const textForEmbedding = combineFieldsForEmbeddings(doc);
        const embedding = await generateEmbeddings(textForEmbedding);

        await collection.mutateIn(docId, [
          MutateInSpec.upsert('text_for_embedding', textForEmbedding),
          MutateInSpec.upsert('embedding', embedding)
        ]);

        console.log(`✅ Processed: ${doc.name || docId}`);
      } catch (error) {
        console.log(`❌ Error processing ${row.id}:`, error.message)
      }
    }));

    // delay between batches
    if (i + BATCH_SIZE < docs.length) {
      await new Promise(resolve => setTimeout(resolve, DELAY_MS))
    }
  }

  console.log('All documents processed!')
  await cluster.close();
}

processDocuments().catch(console.error);
