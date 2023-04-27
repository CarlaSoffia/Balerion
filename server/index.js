const http = require('http');
const https = require('https');
const url = require('url');

const API_BASE_URL = 'https://www.anapioficeandfire.com/api';

async function getCharacterPropById(url) {
  const response = await fetch(url);
  const data = await response.json();
  return data.name;
}

// Define the HTTP server's request handler function
function handleRequest(req, res) {
  const reqUrl = url.parse(req.url, true);

  // Handle /characters endpoint
  if (reqUrl.pathname === '/characters' && reqUrl.query.name) {
    const characterName = reqUrl.query.name;

    https.get(`${API_BASE_URL}/characters/?name=${characterName}`, (response) => {
      let data = '';

      response.on('data', (chunk) => {
        data += chunk;
      });

      response.on('end', async () => {
        // Parse the data as JSON
        const jsonData = JSON.parse(data);
        try {
          // Extract the desired fields
          const result = {
            name: jsonData[0].name,
            gender: jsonData[0].gender,
            culture: jsonData[0].culture,
            born: jsonData[0].born,
            died: jsonData[0].died,
            titles: jsonData[0].titles,
            aliases: jsonData[0].aliases,
          };

          if (jsonData[0].spouse != "") {
            result.spouse = await getCharacterPropById(jsonData[0].spouse);
          }
          if (jsonData[0].father != "") {
            result.father = await getCharacterPropById(jsonData[0].father);
          }
          if (jsonData[0].mother != "") {
            result.mother = await getCharacterPropById(jsonData[0].mother);
          }
          if (jsonData[0].allegiances.length > 0) {
            result.allegiances = await Promise.all(
              jsonData[0].allegiances.map(async (allegiance) => {
                return await getCharacterPropById(allegiance);
              })
            );
          }

          // Send the result as JSON
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify(result));
        }
        catch (error) {
          res.writeHead(404, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ "data": "Character not found" }));
        }
      });
    }).on('error', (error) => {
      console.error(error);
      res.writeHead(500, { 'Content-Type': 'text/plain' });
      res.end('Internal Server Error');
    });

    // Handle /houses endpoint
  } else if (reqUrl.pathname === '/houses' && reqUrl.query.name) {
    const houseName = reqUrl.query.name;

    https.get(`${API_BASE_URL}/houses/?name=${houseName}`, (response) => {
      let data = '';

      response.on('data', (chunk) => {
        data += chunk;
      });

      response.on('end', async () => {
        // Parse the data as JSON
        const jsonData = JSON.parse(data);
        // Extract the desired fields
        try {
          const result = {
            name: jsonData[0].name,
            region: jsonData[0].region,
            coatOfArms: jsonData[0].coatOfArms,
            words: jsonData[0].words,
            titles: jsonData[0].titles,
            seats: jsonData[0].seats,
            ancestralWeapons: jsonData[0].ancestralWeapons,
            swornMembers: jsonData[0].swornMembers
          };
          if (jsonData[0].founder != "") {
            result.founder = await getCharacterPropById(jsonData[0].founder);
          }
          if (jsonData[0].swornMembers.length > 0) {
            result.swornMembers = await Promise.all(
              jsonData[0].swornMembers.map(async (member) => {
                return await getCharacterPropById(member);
              })
            );
          }
          // Send the result as JSON
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify(result));
        }
        catch (error) {
          res.writeHead(404, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ "data": "House not found" }));
        }
      });
    }).on('error', (error) => {
      console.error(error);
      res.writeHead(500, { 'Content-Type': 'text/plain' });
      res.end('Internal Server Error');
    });

    // Handle invalid endpoint or missing query parameter
  } else {
    res.writeHead(400, { 'Content-Type': 'text/plain' });
    res.end('Bad Request');
  }
}

// Create and start the HTTP server
const server = http.createServer(handleRequest);
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log('Server listening on http://localhost:3000');
});
