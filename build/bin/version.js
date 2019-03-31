var fs = require('fs');
var path = require('path');
var version = process.env.VERSION || require('../../package.json').version;
var content = { };
if (!content[version]) content[version] = '1.0';
fs.writeFileSync(path.resolve(__dirname, '../../versions.json'), JSON.stringify(content));