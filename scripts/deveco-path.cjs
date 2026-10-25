const fs = require('fs'), path = require('path');
module.exports = function devEcoHome() {
  const home = process.env.TASK_IDE_HOME || process.env.DEVECO_HOME;
  if (!home || !fs.existsSync(path.join(home, 'tools', 'node', 'node.exe'))) {
    throw new Error('Set TASK_IDE_HOME to your DevEco Studio installation directory. See README.md.');
  }
  return path.resolve(home);
};
