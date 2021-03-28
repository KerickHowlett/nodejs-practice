const fileSystem = require( 'fs' );

const requestHandler = ( request, response ) => {

    const url = request.url;
    const method = request.method;

    if ( url === '/' ) {

        // Generate form template on landing page.
        response.write( '<html>' );
        response.write( '<head><title>Enter Message</title></head>' );
        response.write( '<body><form action="/message" method="POST"><input type="text" name="message"><button type="submit">Send</button></form></body>' );
        response.write( '<html>' );
        return response.end();
    
    }

    // Logic to process on form submissions.
    if ( url === '/message' && method === 'POST' ) {

        const body = []; // Setup body of buffer.

        // Populating body array with stream of buffered data.
        request.on( 'data', ( chunk ) => {
            console.log( chunk );
            body.push( chunk );
        } );

        // Parsing buffered code and injecting it into text file at the
        // end of the stream.
        request.on( 'end', () => {

            const parsedBody = Buffer.concat( body ).toString();
            const message = parsedBody.split( '=' )[ 1 ];

            fileSystem.writeFile( 'message.txt', message, ( error ) => {
                // Redirecting back to landing page.
                response.statusCode = 302;
                response.setHeader( 'Location', '/' );
                return response.end(); // Ending API call.
            } );

        } );

    }

    response.setHeader( 'Content-Type', 'text/html' );
    response.write( '<html>' );
    response.write( '<head><title>My First Page</title></head>' );
    response.write( '<body><h1>Hello from my Node.js Server!</h1></body>' );
    response.write( '<html>' );
    response.end();

};

// module.exports = requestHandler;

// module.exports = {
//     handler: requestHandler,
//     someText: 'Some hard coded text.'
// };

// module.exports.handler = requestHandler;
// module.exports.someText = 'Some text';

exports.handler = requestHandler;
exports.someText = 'Some hard coded text.';