const validateProduct = (req, res, next) => {
    const { title, price, description, category, weight, section, rating } = req.body;
    let errors = [];

    // Check required fields
    if (!title || title.trim() === "") errors.push("Please enter the product name.");
    if (!price || isNaN(price) || price <= 0) errors.push("Please enter a valid price (a positive number).");
    if (!description || description.trim() === "") errors.push("Please enter a product description.");
    if (!category || category.trim() === "") errors.push("Please select a category.");
    if (!weight || isNaN(weight) || weight <= 0) errors.push("Please enter the product weight (a positive number).");
    if (!section) {
        errors.push("Please select a section.");
    } else if (!["Electronics", "Clothing", "Groceries", "Furniture"].includes(section)) {
        errors.push("Invalid section. Choose from: Electronics, Clothing, Groceries, Furniture.");
    }

    // If errors exist, return a response
    if (errors.length > 0) {
        return res.status(400).json({
            status: "fail",
            message: "Validation error",
            errors
        });
    }

    next(); // Proceed if no errors
};

module.exports = validateProduct;
