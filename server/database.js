const { Client } = require("cassandra-driver");

async function run() {
    const client = new Client({
        cloud: {
            secureConnectBundle: "secure-connect-testdb.zip",
        },
        credentials: {username: "testdb", password: "password" },
    });

    await client.connect();

    const rs = await client.execute("SELECT * FROM system.local"); // For now it should return 1 row
    console.log(`Your cluster returned ${rs.rowLength} rows`);

    await client.shutdown();
}

run();