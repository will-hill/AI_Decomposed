class PoolingLayer {

    pool(image, size) {
        let poolOut = [], row;

        for (let i = 0; i < size; i++) {
            poolOut.push(row = []);
            for (let j = 0; j < size; j++) {
                row.push(_max(image, i, j, size));
            }
        }
        return poolOut;
    }

    // TODO fix
    _max(image, i, j, size) {
        let poolingSize = Math.ceil(image.length / size),
            max;

        for (let m = 0; m < poolingSize; m++) {
            for (let n = 0; n < poolingSize; n++) {
                if (!max || max < image[i * 3 + m][j * 3 + n]) {
                    max = image[i * 3 + m][j * 3 + n];
                }
            }
        }
        return max;
    }
}

module.exports = PoolingLayer;