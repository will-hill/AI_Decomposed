const fs = require('fs');
const POOLSIZE = 3;
const data = fs.readFileSync('sample.dat');
const PoolingLayer = require('./pooling-layer');
const e = inputData(data.toString());

// const conv = new ConvolutionalLayer(e, filter);
const pool = new PoolingLayer(POOLSIZE);

console.log('\n');
console.log(e);
console.log('\n\n');
let tensor = pool.pool(e);
console.log(tensor);
console.log('\n\n');

for (let row of pl.pool(convImage)) {
    console.log(row);
}


for (row of pool.layer) {
    console.log(row);
}

function inputData(d) {
    let e = [],
        lines = d.split('\n'),
        line;

    for (let i = 0; i < lines.length - 1; i++) {
        line = lines[i].split(' ');
        e.push(line);
    }
    return e;
}