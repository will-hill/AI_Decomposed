class ConvolutionalLayer {

    _sum(e, filter, i, j) {
        let sum = 0;

        for (let m = 0; m < filter.length; m++) {
            for (let n = 0; n < filter[m].length; n++) {
                sum += e[i + m][j + n] * filter[m][n];
            }
        }
        return sum;
    }

    calc(e, filter) {
        let convOut = [],
            row,
            filterSize = filter.length;

        for (let i = 0; i < e.length - (filterSize - 1); i++) {
            convOut.push(row = []);
            for (let j = 0; j < e[i].length - (filterSize - 1); j++) {
                row.push(this._sum(e, filter, i, j));
            }
        }
        return convOut;
    }


}

module.exports = ConvolutionalLayer;

