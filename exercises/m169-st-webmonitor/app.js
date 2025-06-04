const https = require('https');

const options = {
    hostname: process.env.TARGET,
    method: process.env.METHOD
  };
console.log('Welcome to the M169-ST-Webmonitor!');
console.log('** webmonitor ** Webseite: %s; http-Methode: %s; %dms Interval', options.hostname, options.method, process.env.INTERVAL);
process.on('SIGINT', function() {
  console.log( "\nGracefully shutting down from SIGINT (Ctrl-C)" );
  // some other closing procedures go here
  process.exit(1);
});
  
let i = 1;
let formatString = {timeZone: "Europe/Zurich", day: '2-digit', month: '2-digit', year: 'numeric', hour: "2-digit", minute: "2-digit", second: "2-digit" }
let start = new Date().getTime();
setInterval(() => {    
    start = new Date().getTime();
    currentDate = new Date(start).toLocaleDateString("de-DE",formatString);	
    console.log('Request Nummer: %d; um %s', i++, currentDate);
    var req = https.request(options, (res) => {
	var end = new Date().getTime();    
        var currentDate = new Date(end).toLocaleString("de-DE", formatString);
	var duration = end-start;    
        console.log('Response Status: %s um %s; Dauer: %dms', res.statusCode, currentDate, duration);
    });
    req.on('error', (e) => {
        console.error(e);
      });
    req.end();
}, process.env.INTERVAL)
