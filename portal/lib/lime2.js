'use strict';

const fs = require('fs');

function isBatteryPresent() {
	fs.readFile('/sys/class/power_supply/battery/present', 'utf8', (err, data) => {
    if (err) throw err;
    console.log(data);
  });
}

function isAcPresent() {
  fs.readFile('/sys/class/power_supply/ac/present', 'utf8', (err, data) => {
    if (err) throw err;
    console.log(data);
  });
}

function getBatteryStatus() {
  fs.readFile('/sys/class/power_supply/battery/status', 'utf8', (err, data) => {
    if (err) throw err;
    console.log(data);
  });
}

function getBatteryLevel() {
  fs.readFile('/sys/class/power_supply/battery/capacity', 'utf8', (err, data) => {
    if (err) throw err;
    console.log(data);
  });
}

module.exports = {isBatteryPresent, isAcPresent, getBatteryStatus, getBatteryLevel};
