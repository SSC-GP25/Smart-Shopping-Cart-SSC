const Cart = require('../models/cartModel');
const Product = require('../models/productModel'); 
const User = require('../models/userModel');
const mongoose = require('mongoose')

// Create a new cart
exports.createCart = async (req, res) => {
    try {
        const newCart = new Cart(req.body); 
        await newCart.save();
        res.status(201).json(newCart);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error creating cart' });
    }
};

// Get a cart by cartID
exports.getCartByID = async (req, res) => {
    try {
        const cart = await Cart.findOne({ cartID: req.params.cartID })
            .populate('cartProducts.productID') 
            .populate('recProducts'); 
        if (!cart) {
            return res.status(404).json({ message: 'Cart not found' });
        }
        res.status(200).json(cart);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error retrieving cart' });
    }
};

exports.getAllCarts = async (req, res) => {
    try {
        const carts = await Cart.find({available: false})
            .populate('cartProducts.productID') 
            .populate({
                path: 'userID',
                select: 'name profilePic'
            });
        if (!carts) {
            return res.status(404).json({ message: 'carts not found' });
        }
        console.log(carts);
        res.status(200).json(carts);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error retrieving carts' });
    }
};

// Example updateCart function in your controller
exports.updateCart = async (req, res) => {
    const { cartID } = req.params;
    const updates = req.body; 

    try {
        const cart = await Cart.findOneAndUpdate({ cartID }, updates, { new: true });
        if (!cart) {
            return res.status(404).json({ message: 'Cart not found' });
        }
        res.status(200).json(cart);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error updating cart' });
    }
};


// Set UserID and Change Status to Occupied
exports.addUserToCart = async (req, res, io) => {
    const { userID } = req.body;

    try {
        const cart = await Cart.findOne({ cartID: req.params.cartID }).populate({
            path: 'userID',
            select: 'name profilePic'
        });
        if (!cart) {
            return res.status(404).json({ message: 'Cart not found' });
        }
        if(cart.userID){
            return res.status(400).json({ message: 'Cart is already occupied' });
        }

        cart.userID = userID;

        cart.available = false;
        io.emit('User_Check', {
            addedUser: cart.available === false ? true : false,
            cartID: cart.cartID,
            userID: cart.available === false ? userID : 'No User',
            message: cart.available === false ? 'Cart Connected to a user...!' : `No User Connected to Cart! ${cart.name}`,
        });


        await cart.save();
        const updatedCarts = await Cart.find({available: false})
            .populate('cartProducts.productID') 
            .populate({
                path: 'userID',
                select: 'name profilePic'
            });


        io.emit('cart_on', {
            updatedCarts
        });
        res.status(200).json({
            message: 'User added to cart',
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error adding user to cart and changing cart Status' });
    }
};

// Remove user from cart, clear products, clear recommended products, and change status to 'available'
exports.removeUserFromCart = async (req, res, io) => {
    try {
        const cart = await Cart.findOne({ cartID: req.params.cartID });
        if (!cart || !cart.userID || !req.body.userID ) {
            return res.status(404).json({ message: !cart ? 'Cart not found' : 
                !cart.userID ? 'No User Conntected to Cart' : 
                !req.body.userID ?'No User is Sent' : 'Error!'
             });
        }
        if(req.body.userID != cart.userID) {
            return res.status(400).json({ message: 'You are not Allowed to REmove another User!' });
        }



        cart.userID = null;
        cart.cartProducts = [];
        cart.recProducts = [];
        cart.weightReadings = [];
        cart.detection=[];
        cart.available = true;
        cart.alerts=[];

        io.emit('User_Check', {
            addedUser: cart.available === false ? true : false,
            cartID: cart.cartID,
            userID: cart.available === false ? userID : 'No User',
            message: cart.available === false ? 'Cart Connected to a user...!' : `No User Connected to Cart! ${cart.name}`,
        });

        await cart.save();

            const updatedCarts = await Cart.find({available: false})
            .populate('cartProducts.productID') 
            .populate({
                path: 'userID',
                select: 'name profilePic'
            });

        io.emit('cart_off', {
            updatedCarts
        });

        res.status(200).json({
            message: 'User removed from cart and products cleared',
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error removing user from cart and clearing products' });
    }
};


// Add a recommended product to cart
exports.addRecProductToCart = async (req, res) => {
    const { productIDs } = req.body;  // Expecting an array of product IDs

    try {
        const cart = await Cart.findOne({ cartID: req.params.cartID });
        if (!cart) {
            return res.status(404).json({ message: 'Cart not found' });
        }

        // Iterate through the productIDs and add them to recProducts if not already present
        for (let productID of productIDs) {
            // Check if the recommended product already exists
            const existingRecProduct = cart.recProducts.find(
                item => item.toString() === productID
            );

            if (!existingRecProduct) {
                cart.recProducts.push(productID);
            }
        }

        await cart.save();
        res.status(200).json(cart.recProducts);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error adding recommended products to cart' });
    }
};




exports.addProductToCart = async (req, res, io) => {
    const { barcode } = req.body;

    try {
        // Find the product using the barcode
        const product = await Product.findOne({ barcode });
        if (!product) {
            return res.status(404).json({ message: 'Product not found' });
        }

        const cart = await Cart.findOne({ cartID: req.params.cartID });
        if (!cart) {
            return res.status(404).json({ message: 'Cart not found' });
        }

        const existingProduct = cart.cartProducts.find(
            item => item.productID.toString() === product._id.toString()
        );

        // If the product exists, update the quantity
        if (existingProduct) {
            existingProduct.quantity += 1;
        } else {
            cart.cartProducts.push({
                productID: product._id, // Use found product's ID
                quantity: 1
            });
        }

        await cart.save();

        // Populate product details in the cart
        const updatedCart = await Cart.findOne({ cartID: req.params.cartID })
            .populate('cartProducts.productID')
            .exec();
        console.log(updatedCart.cartProducts);
        console.log(cart.cartID);
        // io.to(`cart_${cartID}`).emit('cartUpdated', updatedCart.cartProducts);
        io.emit('cartUpdated', updatedCart.cartProducts);
        io.emit(`cart_tracking_${cart.cartID}`, updatedCart.cartProducts );


        res.status(200).json(updatedCart.cartProducts.map(item => ({
            productID: item.productID._id, // Send back productID
            quantity: item.quantity
        })));

    } catch (error) {
        res.status(500).json({ error: 'Error adding product to cart' });
    }
};


// Remove a product from the cart with socket.io support
exports.removeProductFromCart = async (req, res, io) => {
    const { productID, quantity } = req.body;

    try {
        const cart = await Cart.findOne({ cartID: req.params.cartID });
        if (!cart) {
            return res.status(404).json({ message: 'Cart not found' });
        }

        const product = cart.cartProducts.find(
            item => item.productID.toString() === productID.toString()
        );

        if (!product) {
            return res.status(404).json({ message: 'Product not found in cart' });
        }

        // If quantity is provided, check if it's valid
        if (quantity) {
            if (quantity <= 0) {
                return res.status(400).json({ message: 'Quantity to remove must be greater than zero' });
            }

            if (quantity > product.quantity) {
                return res.status(400).json({ message: 'Quantity to remove exceeds available quantity' });
            }

            product.quantity -= quantity;

            // If quantity becomes 0 or less, remove the product from the cart
            if (product.quantity <= 0) {
                cart.cartProducts = cart.cartProducts.filter(
                    item => item.productID.toString() !== productID.toString()
                );
            }
        } else {
            // If no quantity is provided, remove the entire product
            cart.cartProducts = cart.cartProducts.filter(
                item => item.productID.toString() !== productID.toString()
            );
        }

        await cart.save();
        
        let updatedCart;
        if(cart.cartProducts){
            updatedCart = await Cart.findOne({ cartID: req.params.cartID })
            .populate('cartProducts.productID')
            .exec();

            // io.emit(`cart_tracking_${cart.cartID}`, updatedCart.cartProducts );
            io.emit('cartUpdated', updatedCart.cartProducts);
        }

        res.status(200).json(updatedCart.cartProducts);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error removing product from cart' });
    }
};

exports.getProducts = async (req, res) => {
    try {
        const cart = await Cart.findOne({ cartID: req.params.cartID })
            .populate('cartProducts.productID')  
            .exec();  

        if (!cart) {
            return res.status(404).json({ message: 'Cart not found' });
        }

        res.status(200).json({
            status:'success',
            totalProducts: cart.cartProducts.length,
            results:cart.cartProducts,
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error retrieving cart' });
    }
};



// const weightResolvers = {}; 
// const weightState = {}; 

// exports.sendCameraResponse = async (req, res, io) => {
//     const { detections } = req.body;
//     const cartID = req.params.cartID;
//     console.log(detections, "THE DATA IS HERE!!!!");

//     try {
//         const cart = await Cart.findOne({ cartID }).populate('cartProducts.productID', 'title');
//         if (!cart) return res.status(404).json({ message: 'Cart not found' });

//         let weightStatus = "unknown";
//         let outItemNotice = null;

//         // Use recent weight state if available
//         const lastWeight = weightState[cartID];
//         const now = Date.now();

//         if (lastWeight && now - lastWeight.updatedAt < 5000) {
//             weightStatus = lastWeight.status;
//             console.log("✅ Using saved weight status:", weightStatus);
//         } else {
//             if (weightResolvers[cartID]) {
//                 clearTimeout(weightResolvers[cartID].timer);
//                 delete weightResolvers[cartID];
//             }

//             const weightPromise = new Promise(resolve => {
//                 weightResolvers[cartID] = {
//                     resolve,
//                     timer: setTimeout(() => {
//                         delete weightResolvers[cartID];
//                         resolve("timeout");
//                     }, 5000)
//                 };
//             });

//             const weightResult = await weightPromise;

//             if (weightResult === "timeout") {
//                 weightStatus = "unknown";
//                 console.log("⚠️ Weight resolution timed out");
//             } else if (weightResult.length >= 2) {
//                 const last = weightResult[weightResult.length - 1].value;
//                 const prev = weightResult[weightResult.length - 2].value;

//                 if (last > prev) weightStatus = "in";
//                 else if (last < prev) weightStatus = "out";
//                 else weightStatus = "same";
//             } else if (weightResult.length === 1) {
//                 weightStatus = "in";
//             }

//             weightState[cartID] = {
//                 status: weightStatus,
//                 updatedAt: Date.now()
//             };
//         }

//         // Work on copies
//         let updatedDetection = [...cart.detection];
//         let updatedCartProducts = [...cart.cartProducts];
//         let updatedAlerts = [...cart.alerts];

//         if (weightStatus === "in" || weightStatus === "out") {
//             detections.forEach(detection => {
//                 const existingDetection = updatedDetection.find(item => item.label === detection.label);

//                 if (weightStatus === "in") {
//                     if (existingDetection) {
//                         existingDetection.quantity += 1;
//                         existingDetection.status = weightStatus;
//                         existingDetection.bbox = detection.bbox;
//                         existingDetection.confidence = detection.confidence;
//                     } else {
//                         updatedDetection.push({
//                             label: detection.label,
//                             confidence: detection.confidence,
//                             status: weightStatus,
//                             quantity: 1
//                         });
//                     }
//                 } else if (weightStatus === "out") {
//                     if (existingDetection) {
//                         if (existingDetection.quantity > 1) {
//                             existingDetection.quantity -= 1;
//                             existingDetection.bbox = detection.bbox;
//                             existingDetection.status = weightStatus;
//                         } else {
//                             updatedDetection = updatedDetection.filter(item => item.label !== detection.label);
//                         }

//                         outItemNotice = `Notice: item ${detection.label} has been removed from your mobile app cart.`;

//                         const index = updatedCartProducts.findIndex(cp =>
//                             cp.productID && cp.productID.title === detection.label
//                         );

//                         if (index !== -1) {
//                             if (updatedCartProducts[index].quantity === 1) {
//                                 updatedCartProducts.splice(index, 1);
//                             } else {
//                                 updatedCartProducts[index].quantity -= 1;
//                             }
//                         }
//                     }
//                 }
//             });
//         }

//         // Authenticity Check
//         let alertField = "Authentic";
//         let mismatchItemName = null;

//         for (const det of updatedDetection) {
//             if (det.quantity <= 0) continue;
//             const cp = updatedCartProducts.find(cp => cp.productID && cp.productID.title === det.label);
//             if (!cp || cp.quantity !== det.quantity) {
//                 alertField = "Not Authentic";
//                 mismatchItemName = det.label;
//                 break;
//             }
//         }

//         for (const cp of updatedCartProducts) {
//             const match = updatedDetection.find(det => det.label === cp.productID.title);
//             if (!match || match.quantity !== cp.quantity) {
//                 alertField = "Not Authentic";
//                 mismatchItemName = cp.productID.title;
//                 break;
//             }
//         }

//         const alertTime = new Date();

//         if (weightStatus === "unknown" || weightStatus === "same") {
//             console.log('⚠️ Detection timeout (No Weight Sensor Signal)');
//             // Don't save anything
//             return res.status(400).json({
//                 message: 'Item Not Added to The Cart or Removed',
//                 detectionStatus: "Detected but weight status unknown"
//             });
//         }

//         if (alertField === "Not Authentic") {
//             console.log('❌ Not Authentic (Mismatch)');
//             updatedAlerts.push({
//                 header: `${cart.cartID}: Product Authenticity`,
//                 message: `Mismatch found for product: ${mismatchItemName}`,
//                 timestamp: alertTime
//             });

//             // ❌ Do not save detection or cartProducts on mismatch
//             await Cart.findOneAndUpdate({ cartID }, {
//                 $set: {
//                     alerts: updatedAlerts
//                 }
//             });

//             io.emit(`cart_alerts_${cart.cartID}`, updatedAlerts);
//             io.emit(`cart_alerts`, updatedAlerts);

//             return res.status(400).json({
//                 message: 'Mismatch between detected items and cart records.',
//                 title: `Please check item: ${mismatchItemName} — quantity mismatch in cart.`,
//                 weightStatus,
//             });
//         }

//         // ✅ Everything is authentic → Save changes
//         await Cart.findOneAndUpdate({ cartID }, {
//             $set: {
//                 detection: updatedDetection,
//                 cartProducts: updatedCartProducts,
//                 alerts: updatedAlerts
//             }
//         });

//         if (weightStatus === "out") {
//             const updatedCart = await Cart.findOne({ cartID }).populate('cartProducts.productID').exec();
//             io.emit(`cart_tracking_${cart.cartID}`, updatedCart.cartProducts);
//             io.emit('cartUpdated', updatedCart.cartProducts);
//         }

//         console.log('✅ Cart updated successfully');
//         return res.status(200).json({
//             message: 'Camera detections processed and cart updated successfully.',
//             weightStatus,
//             outItemNotice,
//         });

//     } catch (error) {
//         console.error('Error in sendCameraResponse:', error);
//         res.status(500).json({ message: 'Internal server error' });
//     }
// };




// exports.sendWeightResponse = async (req, res) => {
//     const { weight } = req.body;
//     const cartID = req.params.cartID;

//     try {
//         const cart = await Cart.findOne({ cartID: cartID });
//         if (!cart) return res.status(404).json({ message: 'Cart not found' });

//         let status = "N/A";

//         if (cart.weightReadings.length === 0) {
//             status = weight === 0 ? "empty" : "first_item";
//         } else {
//             const lastWeight = cart.weightReadings[cart.weightReadings.length - 1].value;
//             if (weight > lastWeight) status = "in";
//             else if (weight < lastWeight) status = "out";
//             else status = "same";
//         }

//         cart.weightReadings.push({
//             value: weight,
//             timestamp: new Date(),
//             status: status
//         });

//         if (cart.weightReadings.length > 2) {
//             cart.weightReadings = cart.weightReadings.slice(-2);
//         }

//         await cart.save();

//         weightState[cartID] = {
//             status,
//             updatedAt: Date.now()
//         };

//         if (weightResolvers[cartID]) {
//             clearTimeout(weightResolvers[cartID].timer);
//             weightResolvers[cartID].resolve([...cart.weightReadings]);
//             delete weightResolvers[cartID];
//         }

//         res.status(200).json({ message: 'Weight reading saved', comparison: status });

//     } catch (error) {
//         console.error('Error:', error);
//         res.status(500).json({ message: 'Internal server error' });
//     }
// };



// // shared helpers
// const weightResolvers = {};
// const weightState = {};
// const cameraAcknowledged = {};
// const lastMismatchAlertTime = {};
// const lastCameraBlockAlertTime = {};
// const activeAlert = {}; // ensures no overlapping alerts

// // ===================
// // CAMERA CONTROLLER
// // ===================
// exports.sendCameraResponse = async (req, res, io) => {
//   const { detections } = req.body;
//   const cartID = req.params.cartID;

//   console.log(`[CAMERA] detections received for ${cartID}`, detections);

//   try {
//     const cart = await Cart.findOne({ cartID }).populate('cartProducts.productID', 'title');
//     if (!cart) return res.status(404).json({ message: 'Cart not found' });

//     // acknowledge to avoid block alert
//     cameraAcknowledged[cartID] = true;

//     let weightStatus = "unknown";
//     let outItemNotice = null;

//     const lastWeight = weightState[cartID];
//     const now = Date.now();

//     if (lastWeight && now - lastWeight.updatedAt < 5000) {
//       weightStatus = lastWeight.status;
//       console.log(`[CAMERA] using cached weight status (${weightStatus}) for ${cartID}`);
//     } else {
//       // no recent weight, wait for resolver
//       if (weightResolvers[cartID]) {
//         clearTimeout(weightResolvers[cartID].timer);
//         delete weightResolvers[cartID];
//       }

//       const weightPromise = new Promise(resolve => {
//         weightResolvers[cartID] = {
//           resolve,
//           timer: setTimeout(() => {
//             delete weightResolvers[cartID];
//             resolve("timeout");
//           }, 5000)
//         };
//       });

//       const weightResult = await weightPromise;

//       if (weightResult === "timeout") {
//         weightStatus = "unknown";
//         console.log(`[CAMERA] weight resolution timed out for ${cartID}`);
//       } else if (weightResult.length >= 2) {
//         const last = weightResult[weightResult.length - 1].value;
//         const prev = weightResult[weightResult.length - 2].value;
//         weightStatus = last > prev ? "in" : (last < prev ? "out" : "same");
//       } else if (weightResult.length === 1) {
//         weightStatus = "in";
//       }

//       weightState[cartID] = {
//         status: weightStatus,
//         updatedAt: Date.now()
//       };
//     }

//     let updatedDetection = [...cart.detection];
//     let updatedCartProducts = [...cart.cartProducts];
//     let updatedAlerts = [...cart.alerts];

//     // add or remove product based on weight
//     if (weightStatus === "in" || weightStatus === "out") {
//       detections.forEach(detection => {
//         const existing = updatedDetection.find(item => item.label === detection.label);

//         if (weightStatus === "in") {
//           if (existing) {
//             existing.quantity += 1;
//             existing.status = weightStatus;
//             existing.bbox = detection.bbox;
//             existing.confidence = detection.confidence;
//           } else {
//             updatedDetection.push({
//               label: detection.label,
//               confidence: detection.confidence,
//               status: weightStatus,
//               quantity: 1
//             });
//           }
//         } else if (weightStatus === "out") {
//           if (existing) {
//             if (existing.quantity > 1) {
//               existing.quantity -= 1;
//             } else {
//               updatedDetection = updatedDetection.filter(x => x.label !== detection.label);
//             }
//             outItemNotice = `Notice: item ${detection.label} removed from your mobile app cart.`;

//             const idx = updatedCartProducts.findIndex(cp =>
//               cp.productID && cp.productID.title === detection.label
//             );
//             if (idx !== -1) {
//               if (updatedCartProducts[idx].quantity === 1) {
//                 updatedCartProducts.splice(idx, 1);
//               } else {
//                 updatedCartProducts[idx].quantity -= 1;
//               }
//             }
//           }
//         }
//       });
//     }

//     // authenticity check
//     let alertField = "Authentic";
//     let mismatchItemName = null;

//     for (const det of updatedDetection) {
//       const cp = updatedCartProducts.find(cp => cp.productID && cp.productID.title === det.label);
//       if (!cp || cp.quantity !== det.quantity) {
//         alertField = "Not Authentic";
//         mismatchItemName = det.label;
//         break;
//       }
//     }
//     for (const cp of updatedCartProducts) {
//       const match = updatedDetection.find(det => det.label === cp.productID.title);
//       if (!match || match.quantity !== cp.quantity) {
//         alertField = "Not Authentic";
//         mismatchItemName = cp.productID.title;
//         break;
//       }
//     }

//     if (weightStatus === "unknown" || weightStatus === "same") {
//       console.log(`[CAMERA] detection ignored due to unknown/same weight for ${cartID}`);
//       return res.status(400).json({
//         message: 'Item Not Added or Removed',
//         detectionStatus: "Detected but weight status unknown"
//       });
//     }

//     if (alertField === "Not Authentic") {
//       console.log(`[CAMERA] authenticity mismatch for ${mismatchItemName} on ${cartID}`);

//       const now = Date.now();
//       if (
//         (lastMismatchAlertTime[cartID] && now - lastMismatchAlertTime[cartID] < 60_000) ||
//         activeAlert[cartID]
//       ) {
//         console.log(`[CAMERA] skipping duplicate mismatch alert for ${cartID}`);
//       } else {
//         const newAlert = {
//           header: `${cartID}: Product Authenticity`,
//           message: `Mismatch found for product: ${mismatchItemName}`,
//           timestamp: new Date()
//         };
//         updatedAlerts.push(newAlert);

//         const updated = await Cart.findOneAndUpdate(
//           { cartID },
//           { $set: { alerts: updatedAlerts } },
//           { new: true }
//         );

//         const lastAlert = updated.alerts[updated.alerts.length - 1];
//         io.emit(`cart_alerts_${cartID}`, lastAlert);
//         io.emit(`cart_alerts`, lastAlert);

//         lastMismatchAlertTime[cartID] = now;
//         activeAlert[cartID] = true;

//         setTimeout(() => {
//           activeAlert[cartID] = false;
//         }, 5000);

//         console.log(`[CAMERA] mismatch alert emitted for ${cartID}`);
//       }

//       return res.status(400).json({
//         message: 'Mismatch between detected items and cart records.',
//         title: `Please check item: ${mismatchItemName} — quantity mismatch in cart.`,
//         weightStatus
//       });
//     }

//     // authentic update
//     await Cart.findOneAndUpdate(
//       { cartID },
//       {
//         $set: {
//           detection: updatedDetection,
//           cartProducts: updatedCartProducts,
//           alerts: updatedAlerts
//         }
//       }
//     );

//     if (weightStatus === "out") {
//       const updatedCart = await Cart.findOne({ cartID }).populate('cartProducts.productID');
//       io.emit(`cart_tracking_${cartID}`, updatedCart.cartProducts);
//       io.emit('cartUpdated', updatedCart.cartProducts);
//     }

//     console.log(`[CAMERA] cart updated successfully for ${cartID}`);
//     return res.status(200).json({
//       message: 'Camera detections processed and cart updated successfully.',
//       weightStatus,
//       outItemNotice
//     });

//   } catch (err) {
//     console.error(`Error in sendCameraResponse for ${cartID}:`, err);
//     res.status(500).json({ message: "Internal server error" });
//   }
// };

// // ===================
// // WEIGHT CONTROLLER
// // ===================
// exports.sendWeightResponse = async (req, res, io) => {
//   const { weight } = req.body;
//   const cartID = req.params.cartID;

//   try {
//     const cart = await Cart.findOne({ cartID });
//     if (!cart) return res.status(404).json({ message: 'Cart not found' });

//     let status = "N/A";
//     if (cart.weightReadings.length === 0) {
//       status = weight === 0 ? "empty" : "first_item";
//     } else {
//       const lastWeight = cart.weightReadings[cart.weightReadings.length - 1].value;
//       if (weight > lastWeight) status = "in";
//       else if (weight < lastWeight) status = "out";
//       else status = "same";
//     }

//     cart.weightReadings.push({
//       value: weight,
//       timestamp: new Date(),
//       status
//     });

//     if (cart.weightReadings.length > 2) {
//       cart.weightReadings = cart.weightReadings.slice(-2);
//     }

//     await cart.save();

//     weightState[cartID] = {
//       status,
//       updatedAt: Date.now()
//     };

//     // reset camera ack
//     cameraAcknowledged[cartID] = false;

//     if (weightResolvers[cartID]) {
//       clearTimeout(weightResolvers[cartID].timer);
//       weightResolvers[cartID].resolve([...cart.weightReadings]);
//       delete weightResolvers[cartID];
//     }

//     if ((status === "in" || status === "first_item") && cart.detection.length === 0) {
//       setTimeout(async () => {
//         // fresh read
//         const acknowledgedNow = cameraAcknowledged[cartID];
//         if (!acknowledgedNow) {
//           const now = Date.now();
//           if (
//             (lastCameraBlockAlertTime[cartID] && now - lastCameraBlockAlertTime[cartID] < 60_000) ||
//             activeAlert[cartID]
//           ) {
//             console.log(`[WEIGHT] skipping duplicate or overlapping camera block alert for ${cartID}`);
//             return;
//           }

//           const updatedCart = await Cart.findOne({ cartID });
//           const newAlert = {
//             header: `${cartID}: Camera Blocked`,
//             message: "There is an object blocking the camera, please clear the view.",
//             timestamp: new Date()
//           };
//           updatedCart.alerts.push(newAlert);
//           await updatedCart.save();

//           const savedAlert = updatedCart.alerts[updatedCart.alerts.length - 1];

//           io.emit(`cart_alerts_${cartID}`, savedAlert);
//           io.emit(`cart_alerts`, savedAlert);

//           lastCameraBlockAlertTime[cartID] = now;
//           activeAlert[cartID] = true;

//           setTimeout(() => {
//             activeAlert[cartID] = false;
//           }, 5000);

//           console.log(`[WEIGHT] camera block alert emitted for ${cartID}`);
//         } else {
//           console.log(`[WEIGHT] camera acknowledged in time for ${cartID}, no block alert.`);
//         }
//       }, 5000);
//     }

//     res.status(200).json({ message: "Weight reading saved", comparison: status });

//   } catch (err) {
//     console.error(`Error in sendWeightResponse for ${cartID}:`, err);
//     res.status(500).json({ message: "Internal server error" });
//   }
// };


// // shared helpers
// const weightResolvers = {};
// const weightState = {};
// const cameraAcknowledged = {};
// const lastMismatchAlertTime = {};
// const lastCameraBlockAlertTime = {};
// const activeMismatchAlert = {};
// const activeBlockAlert = {};

// // ===================
// // CAMERA CONTROLLER
// // ===================
// exports.sendCameraResponse = async (req, res, io) => {
//   const { detections } = req.body;
//   const cartID = req.params.cartID;

//   console.log(`[CAMERA] detections received for ${cartID}`, detections);

//   try {
//     const cart = await Cart.findOne({ cartID }).populate('cartProducts.productID', 'title');
//     if (!cart) return res.status(404).json({ message: 'Cart not found' });

//     // camera seen items
//     cameraAcknowledged[cartID] = true;

//     let weightStatus = "unknown";
//     let outItemNotice = null;

//     const lastWeight = weightState[cartID];
//     const now = Date.now();

//     if (lastWeight && now - lastWeight.updatedAt < 1500) {
//       weightStatus = lastWeight.status;
//       console.log(`[CAMERA] using cached weight status (${weightStatus}) for ${cartID}`);
//     } else {
//       if (weightResolvers[cartID]) {
//         clearTimeout(weightResolvers[cartID].timer);
//         delete weightResolvers[cartID];
//       }

//       const weightPromise = new Promise(resolve => {
//         weightResolvers[cartID] = {
//           resolve,
//           timer: setTimeout(() => {
//             delete weightResolvers[cartID];
//             resolve("timeout");
//           }, 10000)
//         };
//       });

//       const weightResult = await weightPromise;

//       if (weightResult === "timeout") {
//         weightStatus = "unknown";
//         console.log(`[CAMERA] weight resolution timed out for ${cartID}`);
//       } else if (weightResult.length >= 2) {
//         const last = weightResult[weightResult.length - 1].value;
//         const prev = weightResult[weightResult.length - 2].value;
//         weightStatus = last > prev ? "in" : (last < prev ? "out" : "same");
//       } else if (weightResult.length === 1) {
//         weightStatus = "in";
//       }

//       weightState[cartID] = {
//         status: weightStatus,
//         updatedAt: Date.now()
//       };
//     }

//     let updatedDetection = [...cart.detection];
//     let updatedCartProducts = [...cart.cartProducts];
//     let updatedAlerts = [...cart.alerts];

//     // update detection
//     if (weightStatus === "in" || weightStatus === "out") {
//       detections.forEach(detection => {
//         const existing = updatedDetection.find(item => item.label === detection.label);
//         if (weightStatus === "in") {
//           if (existing) {
//             existing.quantity += 1;
//             existing.status = weightStatus;
//             existing.bbox = detection.bbox;
//             existing.confidence = detection.confidence;
//           } else {
//             updatedDetection.push({
//               label: detection.label,
//               confidence: detection.confidence,
//               status: weightStatus,
//               quantity: 1
//             });
//           }
//         } else if (weightStatus === "out") {
//           if (existing) {
//             if (existing.quantity > 1) {
//               existing.quantity -= 1;
//             } else {
//               updatedDetection = updatedDetection.filter(x => x.label !== detection.label);
//             }
//             outItemNotice = `Notice: item ${detection.label} removed from your mobile app cart.`;

//             const idx = updatedCartProducts.findIndex(cp => cp.productID && cp.productID.title === detection.label);
//             if (idx !== -1) {
//               if (updatedCartProducts[idx].quantity === 1) {
//                 updatedCartProducts.splice(idx, 1);
//               } else {
//                 updatedCartProducts[idx].quantity -= 1;
//               }
//             }
//           }
//         }
//       });
//     }

//     // authenticity check
//     let alertField = "Authentic";
//     let mismatchItemName = null;

//     for (const det of updatedDetection) {
//       const cp = updatedCartProducts.find(cp => cp.productID && cp.productID.title === det.label);
//       if (!cp || cp.quantity !== det.quantity) {
//         alertField = "Not Authentic";
//         mismatchItemName = det.label;
//         break;
//       }
//     }
//     for (const cp of updatedCartProducts) {
//       const match = updatedDetection.find(det => det.label === cp.productID.title);
//       if (!match || match.quantity !== cp.quantity) {
//         alertField = "Not Authentic";
//         mismatchItemName = cp.productID.title;
//         break;
//       }
//     }

//     if (weightStatus === "unknown" || weightStatus === "same") {
//       console.log(`[CAMERA] detection ignored due to unknown/same weight for ${cartID}`);
//       return res.status(400).json({
//         message: 'Item Not Added or Removed',
//         detectionStatus: "Detected but weight status unknown"
//       });
//     }

//     if (alertField === "Not Authentic") {
//       console.log(`[CAMERA] authenticity mismatch for ${mismatchItemName} on ${cartID}`);

//       const now = Date.now();
//       if (
//         (lastMismatchAlertTime[cartID] && now - lastMismatchAlertTime[cartID] < 60_000) ||
//         activeMismatchAlert[cartID]
//       ) {
//         console.log(`[CAMERA] skipping duplicate mismatch alert for ${cartID}`);
//       } else {
//         const newAlert = {
//           header: `${cartID}: Product Authenticity`,
//           message: `Mismatch found for product: ${mismatchItemName}`,
//           timestamp: new Date()
//         };
//         updatedAlerts.push(newAlert);

//         const updated = await Cart.findOneAndUpdate(
//           { cartID },
//           { $set: { alerts: updatedAlerts } },
//           { new: true }
//         );

//         const lastAlert = updated.alerts[updated.alerts.length - 1];
//         io.emit(`cart_alerts_${cartID}`, lastAlert);
//         io.emit(`cart_alerts`, lastAlert);

//         lastMismatchAlertTime[cartID] = now;
//         activeMismatchAlert[cartID] = true;

//         // while mismatch is active, block alerts disabled
//         activeBlockAlert[cartID] = true;

//         setTimeout(() => {
//           activeMismatchAlert[cartID] = false;
//           activeBlockAlert[cartID] = false;
//         }, 5000);

//         console.log(`[CAMERA] mismatch alert emitted for ${cartID}`);
//       }

//       return res.status(400).json({
//         message: 'Mismatch between detected items and cart records.',
//         title: `Please check item: ${mismatchItemName} — quantity mismatch in cart.`,
//         weightStatus
//       });
//     }

//     // authentic
//     await Cart.findOneAndUpdate(
//       { cartID },
//       {
//         $set: {
//           detection: updatedDetection,
//           cartProducts: updatedCartProducts,
//           alerts: updatedAlerts
//         }
//       }
//     );

//     if (weightStatus === "out") {
//       const updatedCart = await Cart.findOne({ cartID }).populate('cartProducts.productID');
//       io.emit(`cart_tracking_${cartID}`, updatedCart.cartProducts);
//       io.emit('cartUpdated', updatedCart.cartProducts);
//     }

//     console.log(`[CAMERA] cart updated successfully for ${cartID}`);
//     return res.status(200).json({
//       message: 'Camera detections processed and cart updated successfully.',
//       weightStatus,
//       outItemNotice
//     });

//   } catch (err) {
//     console.error(`Error in sendCameraResponse for ${cartID}:`, err);
//     res.status(500).json({ message: "Internal server error" });
//   }
// };

// // ===================
// // WEIGHT CONTROLLER
// // ===================
// exports.sendWeightResponse = async (req, res, io) => {
//   const { weight } = req.body;
//   const cartID = req.params.cartID;

//   try {
//     const cart = await Cart.findOne({ cartID });
//     if (!cart) return res.status(404).json({ message: 'Cart not found' });

//     let status = "N/A";
//     if (cart.weightReadings.length === 0) {
//       status = weight === 0 ? "empty" : "first_item";
//     } else {
//       const lastWeight = cart.weightReadings[cart.weightReadings.length - 1].value;
//       if (weight > lastWeight) status = "in";
//       else if (weight < lastWeight) status = "out";
//       else status = "same";
//     }

//     cart.weightReadings.push({
//       value: weight,
//       timestamp: new Date(),
//       status
//     });

//     if (cart.weightReadings.length > 2) {
//       cart.weightReadings = cart.weightReadings.slice(-2);
//     }

//     await cart.save();

//     weightState[cartID] = {
//       status,
//       updatedAt: Date.now()
//     };

//     cameraAcknowledged[cartID] = false;

//     if (weightResolvers[cartID]) {
//       clearTimeout(weightResolvers[cartID].timer);
//       weightResolvers[cartID].resolve([...cart.weightReadings]);
//       delete weightResolvers[cartID];
//     }

//     // block alert only if mismatch is not active
//     if ((status === "in" || status === "first_item") && cart.detection.length === 0 && !activeMismatchAlert[cartID] && !activeBlockAlert[cartID]) {
//       setTimeout(async () => {
//         const acknowledgedNow = cameraAcknowledged[cartID];
//         if (!acknowledgedNow) {
//           const now = Date.now();
//           if (
//             (lastCameraBlockAlertTime[cartID] && now - lastCameraBlockAlertTime[cartID] < 60_000) ||
//             activeBlockAlert[cartID]
//           ) {
//             console.log(`[WEIGHT] skipping duplicate or overlapping camera block alert for ${cartID}`);
//             return;
//           }

//           const updatedCart = await Cart.findOne({ cartID });
//           const newAlert = {
//             header: `${cartID}: Camera Blocked`,
//             message: "There is an object blocking the camera, please clear the view.",
//             timestamp: new Date()
//           };
//           updatedCart.alerts.push(newAlert);
//           await updatedCart.save();

//           const savedAlert = updatedCart.alerts[updatedCart.alerts.length - 1];

//           io.emit(`cart_alerts_${cartID}`, savedAlert);
//           io.emit(`cart_alerts`, savedAlert);

//           lastCameraBlockAlertTime[cartID] = now;
//           activeBlockAlert[cartID] = true;

//           setTimeout(() => {
//             activeBlockAlert[cartID] = false;
//           }, 5000);

//           console.log(`[WEIGHT] camera block alert emitted for ${cartID}`);
//         } else {
//           console.log(`[WEIGHT] camera acknowledged in time for ${cartID}, no block alert.`);
//         }
//       }, 5000);
//     }

//     res.status(200).json({ message: "Weight reading saved", comparison: status });

//   } catch (err) {
//     console.error(`Error in sendWeightResponse for ${cartID}:`, err);
//     res.status(500).json({ message: "Internal server error" });
//   }
// };


//Working!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// // shared helpers
// const weightResolvers = {};
// const weightState = {};
// const cameraAcknowledged = {};
// const lastMismatchAlertTime = {};
// const lastCameraBlockAlertTime = {};
// const activeMismatchAlert = {};
// const activeBlockAlert = {};
// const lastCameraSuccess = {}; // NEW FLAG


// // ===================
// // CAMERA CONTROLLER
// // ===================
// exports.sendCameraResponse = async (req, res, io) => {
//   const { detections } = req.body;
//   const cartID = req.params.cartID;

//   console.log(`[CAMERA] detections received for ${cartID}`, detections);

//   try {
//     const cart = await Cart.findOne({ cartID }).populate('cartProducts.productID', 'title');
//     if (!cart) return res.status(404).json({ message: 'Cart not found' });

//     cameraAcknowledged[cartID] = true;

//     let weightStatus = "unknown";
//     let outItemNotice = null;

//     const lastWeight = weightState[cartID];
//     const now = Date.now();

//     if (lastWeight && now - lastWeight.updatedAt < 1500) {
//       weightStatus = lastWeight.status;
//       console.log(`[CAMERA] using cached weight status (${weightStatus}) for ${cartID}`);
//     } else {
//       if (weightResolvers[cartID]) {
//         clearTimeout(weightResolvers[cartID].timer);
//         delete weightResolvers[cartID];
//       }

//       const weightPromise = new Promise(resolve => {
//         weightResolvers[cartID] = {
//           resolve,
//           timer: setTimeout(() => {
//             delete weightResolvers[cartID];
//             resolve("timeout");
//           }, 10000)
//         };
//       });

//       const weightResult = await weightPromise;

//       if (weightResult === "timeout") {
//         weightStatus = "unknown";
//         console.log(`[CAMERA] weight resolution timed out for ${cartID}`);
//       } else if (weightResult.length >= 2) {
//         const last = weightResult[weightResult.length - 1].value;
//         const prev = weightResult[weightResult.length - 2].value;
//         weightStatus = last > prev ? "in" : (last < prev ? "out" : "same");
//       } else if (weightResult.length === 1) {
//         weightStatus = "in";
//       }

//       weightState[cartID] = {
//         status: weightStatus,
//         updatedAt: Date.now()
//       };
//     }

//     let updatedDetection = [...cart.detection];
//     let updatedCartProducts = [...cart.cartProducts];
//     let updatedAlerts = [...cart.alerts];

//     if (weightStatus === "in" || weightStatus === "out") {
//       detections.forEach(detection => {
//         const existing = updatedDetection.find(item => item.label === detection.label);
//         if (weightStatus === "in") {
//           if (existing) {
//             existing.quantity += 1;
//             existing.status = weightStatus;
//             existing.bbox = detection.bbox;
//             existing.confidence = detection.confidence;
//           } else {
//             updatedDetection.push({
//               label: detection.label,
//               confidence: detection.confidence,
//               status: weightStatus,
//               quantity: 1
//             });
//           }
//         } else if (weightStatus === "out") {
//           if (existing) {
//             if (existing.quantity > 1) {
//               existing.quantity -= 1;
//             } else {
//               updatedDetection = updatedDetection.filter(x => x.label !== detection.label);
//             }
//             outItemNotice = `Notice: item ${detection.label} removed from your mobile app cart.`;

//             const idx = updatedCartProducts.findIndex(cp => cp.productID && cp.productID.title === detection.label);
//             if (idx !== -1) {
//               if (updatedCartProducts[idx].quantity === 1) {
//                 updatedCartProducts.splice(idx, 1);
//               } else {
//                 updatedCartProducts[idx].quantity -= 1;
//               }
//             }
//           }
//         }
//       });
//     }

//     // authenticity check
//     let alertField = "Authentic";
//     let mismatchItemName = null;

//     for (const det of updatedDetection) {
//       const cp = updatedCartProducts.find(cp => cp.productID && cp.productID.title === det.label);
//       if (!cp || cp.quantity !== det.quantity) {
//         alertField = "Not Authentic";
//         mismatchItemName = det.label;
//         break;
//       }
//     }
//     for (const cp of updatedCartProducts) {
//       const match = updatedDetection.find(det => det.label === cp.productID.title);
//       if (!match || match.quantity !== cp.quantity) {
//         alertField = "Not Authentic";
//         mismatchItemName = cp.productID.title;
//         break;
//       }
//     }

//     if (weightStatus === "unknown" || weightStatus === "same") {
//       console.log(`[CAMERA] detection ignored due to unknown/same weight for ${cartID}`);
//       return res.status(400).json({
//         message: 'Item Not Added or Removed',
//         detectionStatus: "Detected but weight status unknown"
//       });
//     }

//     if (alertField === "Not Authentic") {
//       console.log(`[CAMERA] authenticity mismatch for ${mismatchItemName} on ${cartID}`);

//       if (
//         (lastMismatchAlertTime[cartID] && now - lastMismatchAlertTime[cartID] < 60_000) ||
//         activeMismatchAlert[cartID]
//       ) {
//         console.log(`[CAMERA] skipping duplicate mismatch alert for ${cartID}`);
//       } else {
//         const newAlert = {
//           header: `${cartID}: Product Authenticity`,
//           message: `Mismatch found for product: ${mismatchItemName}`,
//           timestamp: new Date()
//         };
//         updatedAlerts.push(newAlert);

//         const updated = await Cart.findOneAndUpdate(
//           { cartID },
//           { $set: { alerts: updatedAlerts } },
//           { new: true }
//         );

//         const lastAlert = updated.alerts[updated.alerts.length - 1];
//         io.emit(`cart_alerts_${cartID}`, lastAlert);
//         io.emit(`cart_alerts`, lastAlert);

//         lastMismatchAlertTime[cartID] = now;
//         activeMismatchAlert[cartID] = true;

//         // while mismatch is active, block alerts disabled
//         activeBlockAlert[cartID] = true;

//         setTimeout(() => {
//           activeMismatchAlert[cartID] = false;
//           activeBlockAlert[cartID] = false;
//         }, 5000);

//         console.log(`[CAMERA] mismatch alert emitted for ${cartID}`);
//       }

//       return res.status(400).json({
//         message: 'Mismatch between detected items and cart records.',
//         title: `Please check item: ${mismatchItemName} — quantity mismatch in cart.`,
//         weightStatus
//       });
//     }

//     // authentic
//     await Cart.findOneAndUpdate(
//       { cartID },
//       {
//         $set: {
//           detection: updatedDetection,
//           cartProducts: updatedCartProducts,
//           alerts: updatedAlerts
//         }
//       }
//     );

//     // FLAG successful authentic to skip block-check temporarily
//     lastCameraSuccess[cartID] = true;
//     setTimeout(() => {
//       lastCameraSuccess[cartID] = false;
//     }, 5000);

//     if (weightStatus === "out") {
//       const updatedCart = await Cart.findOne({ cartID }).populate('cartProducts.productID');
//       io.emit(`cart_tracking_${cartID}`, updatedCart.cartProducts);
//       io.emit('cartUpdated', updatedCart.cartProducts);
//     }

//     console.log(`[CAMERA] cart updated successfully for ${cartID}`);
//     return res.status(200).json({
//       message: 'Camera detections processed and cart updated successfully.',
//       weightStatus,
//       outItemNotice
//     });

//   } catch (err) {
//     console.error(`Error in sendCameraResponse for ${cartID}:`, err);
//     res.status(500).json({ message: "Internal server error" });
//   }
// };

// // ===================
// // WEIGHT CONTROLLER
// // ===================
// exports.sendWeightResponse = async (req, res, io) => {
//   const { weight } = req.body;
//   const cartID = req.params.cartID;

//   try {
//     const cart = await Cart.findOne({ cartID });
//     if (!cart) return res.status(404).json({ message: 'Cart not found' });

//     let status = "N/A";
//     if (cart.weightReadings.length === 0) {
//       status = weight === 0 ? "empty" : "first_item";
//     } else {
//       const lastWeight = cart.weightReadings[cart.weightReadings.length - 1].value;
//       if (weight > lastWeight) status = "in";
//       else if (weight < lastWeight) status = "out";
//       else status = "same";
//     }

//     cart.weightReadings.push({
//       value: weight,
//       timestamp: new Date(),
//       status
//     });

//     if (cart.weightReadings.length > 2) {
//       cart.weightReadings = cart.weightReadings.slice(-2);
//     }

//     await cart.save();

//     weightState[cartID] = {
//       status,
//       updatedAt: Date.now()
//     };

//     cameraAcknowledged[cartID] = false;

//     if (weightResolvers[cartID]) {
//       clearTimeout(weightResolvers[cartID].timer);
//       weightResolvers[cartID].resolve([...cart.weightReadings]);
//       delete weightResolvers[cartID];
//     }

//     // block alert only if mismatch is not active and no recent authentic
//     if (
//       (status === "in" || status === "first_item") &&
//       cart.detection.length === 0 &&
//       !activeMismatchAlert[cartID] &&
//       !activeBlockAlert[cartID] &&
//       !lastCameraSuccess[cartID]
//     ) {
//       setTimeout(async () => {
//         const acknowledgedNow = cameraAcknowledged[cartID];
//         if (!acknowledgedNow) {
//           const now = Date.now();
//           if (
//             (lastCameraBlockAlertTime[cartID] && now - lastCameraBlockAlertTime[cartID] < 60_000) ||
//             activeBlockAlert[cartID]
//           ) {
//             console.log(`[WEIGHT] skipping duplicate or overlapping camera block alert for ${cartID}`);
//             return;
//           }

//           const updatedCart = await Cart.findOne({ cartID });
//           const newAlert = {
//             header: `${cartID}: Camera Blocked`,
//             message: "There is an object blocking the camera, please clear the view.",
//             timestamp: new Date()
//           };
//           updatedCart.alerts.push(newAlert);
//           await updatedCart.save();

//           const savedAlert = updatedCart.alerts[updatedCart.alerts.length - 1];

//           io.emit(`cart_alerts_${cartID}`, savedAlert);
//           io.emit(`cart_alerts`, savedAlert);

//           lastCameraBlockAlertTime[cartID] = now;
//           activeBlockAlert[cartID] = true;

//           setTimeout(() => {
//             activeBlockAlert[cartID] = false;
//           }, 5000);

//           console.log(`[WEIGHT] camera block alert emitted for ${cartID}`);
//         } else {
//           console.log(`[WEIGHT] camera acknowledged in time for ${cartID}, no block alert.`);
//         }
//       }, 5000);
//     }

//     res.status(200).json({ message: "Weight reading saved", comparison: status });

//   } catch (err) {
//     console.error(`Error in sendWeightResponse for ${cartID}:`, err);
//     res.status(500).json({ message: "Internal server error" });
//   }
// };


// shared helpers
const weightResolvers = {};
const weightState = {};
const cameraAcknowledged = {};
const lastMismatchAlertTime = {};
const lastCameraBlockAlertTime = {};
const activeMismatchAlert = {};
const activeBlockAlert = {};
const lastCameraSuccess = {};
const cameraTriggeredFirst = {};  // new flag

// ===================
// CAMERA CONTROLLER
// ===================
exports.sendCameraResponse = async (req, res, io) => {
  const { detections } = req.body;
  const cartID = req.params.cartID;

  console.log(`[CAMERA] detections received for ${cartID}`, detections);

  try {
    const cart = await Cart.findOne({ cartID }).populate('cartProducts.productID', 'title');
    if (!cart) return res.status(404).json({ message: 'Cart not found' });

    // mark camera acknowledged
    cameraAcknowledged[cartID] = true;

    // set flag to indicate camera came first
    cameraTriggeredFirst[cartID] = 1;
    setTimeout(() => {
      cameraTriggeredFirst[cartID] = 0;
    }, 5000);

    let weightStatus = "unknown";
    let outItemNotice = null;

    const lastWeight = weightState[cartID];
    const now = Date.now();

    if (lastWeight && now - lastWeight.updatedAt < 1500) {
      weightStatus = lastWeight.status;
      console.log(`[CAMERA] using cached weight status (${weightStatus}) for ${cartID}`);
    } else {
      if (weightResolvers[cartID]) {
        clearTimeout(weightResolvers[cartID].timer);
        delete weightResolvers[cartID];
      }

      const weightPromise = new Promise(resolve => {
        weightResolvers[cartID] = {
          resolve,
          timer: setTimeout(() => {
            delete weightResolvers[cartID];
            resolve("timeout");
          }, 10000)
        };
      });

      const weightResult = await weightPromise;

      if (weightResult === "timeout") {
        weightStatus = "unknown";
        console.log(`[CAMERA] weight resolution timed out for ${cartID}`);
      } else if (weightResult.length >= 2) {
        const last = weightResult[weightResult.length - 1].value;
        const prev = weightResult[weightResult.length - 2].value;
        weightStatus = last > prev ? "in" : (last < prev ? "out" : "same");
      } else if (weightResult.length === 1) {
        weightStatus = "in";
      }

      weightState[cartID] = {
        status: weightStatus,
        updatedAt: Date.now()
      };
    }

    let updatedDetection = [...cart.detection];
    let updatedCartProducts = [...cart.cartProducts];
    let updatedAlerts = [...cart.alerts];

    if (weightStatus === "in" || weightStatus === "out") {
      detections.forEach(detection => {
        const existing = updatedDetection.find(item => item.label === detection.label);
        if (weightStatus === "in") {
          if (existing) {
            existing.quantity += 1;
            existing.status = weightStatus;
            existing.bbox = detection.bbox;
            existing.confidence = detection.confidence;
          } else {
            updatedDetection.push({
              label: detection.label,
              confidence: detection.confidence,
              status: weightStatus,
              quantity: 1
            });
          }
        } else if (weightStatus === "out") {
          if (existing) {
            if (existing.quantity > 1) {
              existing.quantity -= 1;
            } else {
              updatedDetection = updatedDetection.filter(x => x.label !== detection.label);
            }
            outItemNotice = `Notice: item ${detection.label} removed from your mobile app cart.`;

            const idx = updatedCartProducts.findIndex(cp => cp.productID && cp.productID.title === detection.label);
            if (idx !== -1) {
              if (updatedCartProducts[idx].quantity === 1) {
                updatedCartProducts.splice(idx, 1);
              } else {
                updatedCartProducts[idx].quantity -= 1;
              }
            }
          }
        }
      });
    }

    // authenticity check
    let alertField = "Authentic";
    let mismatchItemName = null;

    for (const det of updatedDetection) {
      const cp = updatedCartProducts.find(cp => cp.productID && cp.productID.title === det.label);
      if (!cp || cp.quantity !== det.quantity) {
        alertField = "Not Authentic";
        mismatchItemName = det.label;
        break;
      }
    }
    for (const cp of updatedCartProducts) {
      const match = updatedDetection.find(det => det.label === cp.productID.title);
      if (!match || match.quantity !== cp.quantity) {
        alertField = "Not Authentic";
        mismatchItemName = cp.productID.title;
        break;
      }
    }

    if (weightStatus === "unknown" || weightStatus === "same") {
      console.log(`[CAMERA] detection ignored due to unknown/same weight for ${cartID}`);
      return res.status(400).json({
        message: 'Item Not Added or Removed',
        detectionStatus: "Detected but weight status unknown"
      });
    }

    if (alertField === "Not Authentic") {
      console.log(`[CAMERA] authenticity mismatch for ${mismatchItemName} on ${cartID}`);

      if (
        (lastMismatchAlertTime[cartID] && now - lastMismatchAlertTime[cartID] < 60_000) ||
        activeMismatchAlert[cartID]
      ) {
        console.log(`[CAMERA] skipping duplicate mismatch alert for ${cartID}`);
      } else {
        const newAlert = {
          header: `${cartID}: Product Authenticity`,
          message: `Mismatch found for product: ${mismatchItemName}`,
          timestamp: new Date()
        };
        updatedAlerts.push(newAlert);

        const updated = await Cart.findOneAndUpdate(
          { cartID },
          { $set: { alerts: updatedAlerts } },
          { new: true }
        );

        const lastAlert = updated.alerts[updated.alerts.length - 1];
        io.emit(`cart_alerts_${cartID}`, lastAlert);
        io.emit(`cart_alerts`, lastAlert);

        lastMismatchAlertTime[cartID] = now;
        activeMismatchAlert[cartID] = true;

        // while mismatch is active, block alerts disabled
        activeBlockAlert[cartID] = true;

        setTimeout(() => {
          activeMismatchAlert[cartID] = false;
          activeBlockAlert[cartID] = false;
        }, 5000);

        console.log(`[CAMERA] mismatch alert emitted for ${cartID}`);
      }

      return res.status(400).json({
        message: 'Mismatch between detected items and cart records.',
        title: `Please check item: ${mismatchItemName} — quantity mismatch in cart.`,
        weightStatus
      });
    }

    // authentic, update cart
    await Cart.findOneAndUpdate(
      { cartID },
      {
        $set: {
          detection: updatedDetection,
          cartProducts: updatedCartProducts,
          alerts: updatedAlerts
        }
      }
    );

    // mark success to help skip block
    lastCameraSuccess[cartID] = true;
    setTimeout(() => {
      lastCameraSuccess[cartID] = false;
    }, 5000);

    if (weightStatus === "out") {
      const updatedCart = await Cart.findOne({ cartID }).populate('cartProducts.productID');
      io.emit(`cart_tracking_${cartID}`, updatedCart.cartProducts);
      io.emit('cartUpdated', updatedCart.cartProducts);
    }

    console.log(`[CAMERA] cart updated successfully for ${cartID}`);
    return res.status(200).json({
      message: 'Camera detections processed and cart updated successfully.',
      weightStatus,
      outItemNotice
    });

  } catch (err) {
    console.error(`Error in sendCameraResponse for ${cartID}:`, err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// ===================
// WEIGHT CONTROLLER
// ===================
exports.sendWeightResponse = async (req, res, io) => {
  const { weight } = req.body;
  const cartID = req.params.cartID;

  try {
    const cart = await Cart.findOne({ cartID });
    if (!cart) return res.status(404).json({ message: 'Cart not found' });

    let status = "N/A";
    if (cart.weightReadings.length === 0) {
      status = weight === 0 ? "empty" : "first_item";
    } else {
      const lastWeight = cart.weightReadings[cart.weightReadings.length - 1].value;
      if (weight > lastWeight) status = "in";
      else if (weight < lastWeight) status = "out";
      else status = "same";
    }

    cart.weightReadings.push({
      value: weight,
      timestamp: new Date(),
      status
    });

    if (cart.weightReadings.length > 2) {
      cart.weightReadings = cart.weightReadings.slice(-2);
    }

    await cart.save();

    weightState[cartID] = {
      status,
      updatedAt: Date.now()
    };

    cameraAcknowledged[cartID] = false;

    if (weightResolvers[cartID]) {
      clearTimeout(weightResolvers[cartID].timer);
      weightResolvers[cartID].resolve([...cart.weightReadings]);
      delete weightResolvers[cartID];
    }

    // block alert only if:
    // - weight is in / first_item
    // - no detection from camera
    // - no mismatch alert active
    // - no camera recent success
    // - no camera triggered first
    if (
      (status === "in" || status === "first_item") &&
      cart.detection.length === 0 &&
      !activeMismatchAlert[cartID] &&
      !activeBlockAlert[cartID] &&
      !lastCameraSuccess[cartID] &&
      !cameraTriggeredFirst[cartID]
    ) {
      setTimeout(async () => {
        const acknowledgedNow = cameraAcknowledged[cartID];
        if (!acknowledgedNow) {
          const now = Date.now();
          if (
            (lastCameraBlockAlertTime[cartID] && now - lastCameraBlockAlertTime[cartID] < 60_000) ||
            activeBlockAlert[cartID]
          ) {
            console.log(`[WEIGHT] skipping duplicate or overlapping camera block alert for ${cartID}`);
            return;
          }

          const updatedCart = await Cart.findOne({ cartID });
          const newAlert = {
            header: `${cartID}: Camera Blocked`,
            message: "There is an object blocking the camera, please clear the view.",
            timestamp: new Date()
          };
          updatedCart.alerts.push(newAlert);
          await updatedCart.save();

          const savedAlert = updatedCart.alerts[updatedCart.alerts.length - 1];
          io.emit(`cart_alerts_${cartID}`, savedAlert);
          io.emit(`cart_alerts`, savedAlert);

          lastCameraBlockAlertTime[cartID] = now;
          activeBlockAlert[cartID] = true;

          setTimeout(() => {
            activeBlockAlert[cartID] = false;
          }, 5000);

          console.log(`[WEIGHT] camera block alert emitted for ${cartID}`);
        } else {
          console.log(`[WEIGHT] camera acknowledged in time for ${cartID}, no block alert.`);
        }
      }, 5000);
    }

    res.status(200).json({ message: "Weight reading saved", comparison: status });

  } catch (err) {
    console.error(`Error in sendWeightResponse for ${cartID}:`, err);
    res.status(500).json({ message: "Internal server error" });
  }
};
