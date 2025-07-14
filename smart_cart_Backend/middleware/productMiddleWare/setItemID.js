
const setItem_ID = function (next) {
    if (this.barcode && !this.item_id) {
        this.item_id = this.barcode;
    }
    next();
}

module.exports = setItem_ID;