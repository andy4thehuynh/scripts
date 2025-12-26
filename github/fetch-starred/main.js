// Fetches Github Starred Repos

require('dotenv').config();
const fetch = require('node-fetch');

const GH_USER = process.env.GH_USER;
const GH_TOKEN = process.env.GH_TOKEN;

if (!GH_USER || !GH_TOKEN) {
  console.error('Error: GH_USER and GH_TOKEN environment variables must be set.');
  process.exit(1);
}

async function fetchReadme(repo) {
  try {
    const readmeUrl = `https://api.github.com/repos/${repo.owner.login}/${repo.name}/readme`;
    const response = await fetch(readmeUrl, {
      headers: {
        'Authorization': `Bearer ${GH_TOKEN}`,
        'Accept': 'application/vnd.github.v3+json'
      }
    });

    if (response.ok) {
      const data = await response.json();
      return Buffer.from(data.content, 'base64').toString('utf8'); // Base64 encoded, so we decode it
    } else {
      // no README --> 404 error
      return null;
    }
  } catch (error) {
    console.error(`Error fetching README for ${repo.full_name}:`, error);
    return null;
  }
}

/**
 * Fetches all starred repositories for the configured user, including their READMEs.
 */
async function fetchAllStarredReposWithReadmes() {
  console.error(`Fetching starred repositories for ${GH_USER}...`);
  const repos = [];
  let page = 1;
  const perPage = 100;

  // 1. Fetch all starred repositories (paginated)
  while (true) {
    const url = `https://api.github.com/users/${GH_USER}/starred?per_page=${perPage}&page=${page}`;
    const response = await fetch(url, {
      headers: {
        'Authorization': `Bearer ${GH_TOKEN}`,
        'Accept': 'application/vnd.github.v3+json'
      }
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error(`Error fetching starred repos (page ${page}): ${response.status} ${response.statusText}`, errorText);
      break;
    }

    const data = await response.json();
    if (data.length === 0) {
      break; // No more pages
    }

    repos.push(...data);
    page++;
  }
  console.error(`Found ${repos.length} starred repositories.`);

  console.error('Fetching READMEs for each repository...');
  const reposWithReadmes = await Promise.all(
    repos.map(async (repo) => {
      const readmeContent = await fetchReadme(repo);
      return {
        ...repo,
        readme_content: readmeContent
      };
    })
  );

  console.error('All data fetched successfully.');

  // 3. Print the final JSON to stdout
  console.log(JSON.stringify(reposWithReadmes, null, 2));
}

fetchAllStarredReposWithReadmes();
