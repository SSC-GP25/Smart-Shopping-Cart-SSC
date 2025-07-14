
const setAisle = function(next) {
    if (this.isNew || this.isModified('section')) {
        if (this.section === 'electronics') {
            this.aisle = 'A1';
        } else if (this.section === 'clothing') {
            this.aisle = 'B1';
        } else if (this.section === 'groceries') {
            this.aisle = 'C1';
        } else if (this.section === 'furniture') {
            this.aisle = 'D1';
        } else {
            this.aisle = 'Unknown'; 
        }
    }
    next();
};

module.exports = setAisle;
