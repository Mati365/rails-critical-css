const penthouse = require('penthouse');
const process = require('process');
const fs = require('fs');

const FD = {
  STDIN: 0,
  STDOUT: 1,
  STDERR: 2,
};

const config = JSON.parse(fs.readFileSync(FD.STDIN, 'utf-8'));

penthouse(config)
  .then((criticalCss) => {
    fs.writeSync(FD.STDOUT, criticalCss);
  })
  .catch((err) => {
    fs.writeSync(FD.STDERR, err);
    process.exit(1);
  })
