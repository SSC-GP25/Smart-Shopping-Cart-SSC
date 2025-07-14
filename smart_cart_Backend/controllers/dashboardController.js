const Transaction = require('../models/transactionModel');
const Product = require('../models/productModel');
const User = require('../models/userModel');

exports.getRevenueStats = async (req, res) => {
    try {
        const range = req.query.range || "12h";
        const now = new Date();
        let currentStartDate, previousStartDate, previousEndDate;
        let groupBy;

        switch (range) {
            case "24h":
                currentStartDate = new Date(now.getTime() - 24 * 60 * 60 * 1000);
                previousEndDate = new Date(currentStartDate);
                previousStartDate = new Date(currentStartDate.getTime() - 24 * 60 * 60 * 1000);
                groupBy = {
                    hour: { $hour: "$createdAt" },
                    day: { $dayOfMonth: "$createdAt" },
                    month: { $month: "$createdAt" },
                    year: { $year: "$createdAt" }
                };
                break;

            case "12h":
            default:
                currentStartDate = new Date(now.getTime() - 12 * 60 * 60 * 1000);
                previousEndDate = new Date(currentStartDate);
                previousStartDate = new Date(currentStartDate.getTime() - 12 * 60 * 60 * 1000);
                groupBy = {
                    hour: { $hour: "$createdAt" },
                    day: { $dayOfMonth: "$createdAt" },
                    month: { $month: "$createdAt" },
                    year: { $year: "$createdAt" }
                };
                break;

            case "week":
                const dayOfWeek = now.getDay();
                const diffToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
                currentStartDate = new Date(now);
                currentStartDate.setDate(now.getDate() - diffToMonday);
                currentStartDate.setHours(0, 0, 0, 0);

                previousEndDate = new Date(currentStartDate);
                previousStartDate = new Date(currentStartDate.getTime() - 7 * 24 * 60 * 60 * 1000);

                groupBy = {
                    day: { $dayOfWeek: "$createdAt" },
                    month: { $month: "$createdAt" },
                    year: { $year: "$createdAt" }
                };
                break;

            case "4w":
                const currentMonthStart = new Date(now.getFullYear(), now.getMonth(), 1);
                currentStartDate = new Date(now.getTime() - 4 * 7 * 24 * 60 * 60 * 1000);
                if (currentStartDate < currentMonthStart) {
                    currentStartDate = currentMonthStart;
                }

                previousEndDate = new Date(currentStartDate);
                previousStartDate = new Date(currentStartDate.getTime() - 4 * 7 * 24 * 60 * 60 * 1000);

                groupBy = {
                    week: { $week: "$createdAt" },
                    month: { $month: "$createdAt" },
                    year: { $year: "$createdAt" }
                };
                break;

            case "year":
                currentStartDate = new Date(now.getFullYear(), 0, 1);
                previousEndDate = new Date(currentStartDate);
                previousStartDate = new Date(currentStartDate.getFullYear() - 1, 0, 1);

                groupBy = {
                    month: { $month: "$createdAt" },
                    year: { $year: "$createdAt" }
                };
                break;
        }

        const stats = await Transaction.aggregate([
            {
                $facet: {
                    current: [
                        {
                            $match: {
                                createdAt: { $gte: currentStartDate, $lte: now }
                            }
                        },
                        {
                            $group: {
                                _id: groupBy,
                                total: { $sum: "$totalAmount" },
                                count: { $sum: 1 }
                            }
                        },
                        {
                            $sort: {
                                "_id.year": 1,
                                "_id.month": 1,
                                "_id.week": 1,
                                "_id.day": 1,
                                "_id.hour": 1
                            }
                        }
                    ],
                    previous: [
                        {
                            $match: {
                                createdAt: { $gte: previousStartDate, $lt: previousEndDate }
                            }
                        },
                        {
                            $group: {
                                _id: groupBy,
                                total: { $sum: "$totalAmount" },
                                count: { $sum: 1 }
                            }
                        },
                        {
                            $sort: {
                                "_id.year": 1,
                                "_id.month": 1,
                                "_id.week": 1,
                                "_id.day": 1,
                                "_id.hour": 1
                            }
                        }
                    ]
                }
            }
        ]);

        res.status(200).json({
            status: "success",
            message: `Revenue stats for ${range} and previous`,
            current: stats[0].current,
            previous: stats[0].previous
        });

    } catch (err) {
        res.status(500).json({
            status: "fail",
            message: "Something went wrong",
            error: err.message
        });
    }
};



exports.lastWeekOrders = async (req, res) => {
    try {
        const now = new Date();
        const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        const startDate = new Date(sevenDaysAgo.setHours(0, 0, 0, 0));
        const endDate = new Date(now.setHours(0, 0, 0, 0));
        
        const groupBy = {
            day: { $dayOfMonth: "$createdAt" },
            month: { $month: "$createdAt" },
            year: { $year: "$createdAt" }
        };

        const stats = await Transaction.aggregate([
            {
                $match: {
                    createdAt: { $gte: startDate, $lt: endDate }
                }
            },
            {
                $group: {
                    _id: groupBy,
                    total: { $sum: "$totalAmount" },
                    count: { $sum: 1 },
                    totalProducts: { $sum: { $sum: "$products.quantity" } }
                }
            },
            {
                $sort: { "_id.year": 1, "_id.month": 1, "_id.day": 1 }
            }
        ]);

        const totals = stats.reduce(
            (acc, day) => {
                acc.totalAmount += day.total;
                acc.totalTransactions += day.count;
                acc.totalProducts += day.totalProducts || 0;
                return acc;
            },
            { totalAmount: 0, totalTransactions: 0, totalProducts: 0 }
        );

        res.status(200).json({
            status: "success",
            message: `Last 7 Days Orders Found!`,
            data: {
                stats,
                overall: totals
            }
        });

    } catch (err) {
        res.status(500).json({
            status: "fail",
            message: "Something went wrong",
            error: err.message
        });
    }
};


exports.getRecentTransactions = async (req, res) => {
    try {
        const recentTransactions = await Transaction.find()
            .sort({ createdAt: -1 })
            .limit(5)
            .populate("user", "name")
            .select("_id transactionId user createdAt totalAmount paymentMethod");

        res.status(200).json({
            status: "success",
            message: "Found recent transactions",
            data: {
                recentTransactions
            }
        });
    } catch (err) {
        res.status(404).json({
            status: "fail",
            message: "Couldn't find recent transactions",
            error: err.message
        });
    }
};


exports.getTopSoldProducts = async (req, res) => {
    try{
        const products = await Product.find().sort({sales:-1}).limit(5).select("image title price rating sales");
        res.status(200).json({
            status: "sucess",
            message: "Found top sold products",
            data: {
                products 
            }
          });
    } catch (err) {
        res.status(404).json({
            status: "fail",
            message: "Couldn't find top sold products",
            error: err.message
        });
    }
}

exports.getTodayStats = async (req, res) => {
    try {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);

        const todayTransactions = await Transaction.find({
            createdAt: { $gte: today }
        });

        const yesterdayTransactions = await Transaction.find({
            createdAt: { $gte: yesterday, $lt: today }
        });

        const todayStats = {
            orderCount: todayTransactions.length,
            totalRevenue: todayTransactions.reduce((acc, transaction) => acc + transaction.totalAmount, 0),
            totalProducts: todayTransactions.reduce((acc, order) => {
                const orderTotal = order.products.reduce((sum, product) => {
                    return sum + (product.quantity || 0);
                }, 0);
                return acc + orderTotal;
            }, 0)
        };

        const yesterdayStats = {
            orderCount: yesterdayTransactions.length,
            totalRevenue: yesterdayTransactions.reduce((acc, transaction) => acc + transaction.totalAmount, 0),
            totalProducts: yesterdayTransactions.reduce((acc, order) => {
                const orderTotal = order.products.reduce((sum, product) => {
                    return sum + (product.quantity || 0);
                }, 0);
                return acc + orderTotal;
            }, 0)
        };

        let revenueChange = 0;
        if (yesterdayStats.totalRevenue > 0) {
            revenueChange = ((todayStats.totalRevenue - yesterdayStats.totalRevenue) / yesterdayStats.totalRevenue) * 100;
        } else if (todayStats.totalRevenue > 0) {
            revenueChange = 100;
        }

        let orderCountChange = 0;
        if (yesterdayStats.orderCount > 0) {
            orderCountChange = ((todayStats.orderCount - yesterdayStats.orderCount) / yesterdayStats.orderCount) * 100;
        } else if (todayStats.orderCount > 0) {
            orderCountChange = 100;
        }

        let productCountChange = 0;
        if (yesterdayStats.totalProducts > 0) {
            productCountChange = ((todayStats.totalProducts - yesterdayStats.totalProducts) / yesterdayStats.totalProducts) * 100;
        } else if (todayStats.totalProducts > 0) {
            productCountChange = 100;
        }

        res.status(200).json({
            status: "success",
            message: "Today's statistics retrieved successfully",
            data: {
                today: {
                    orderCount: todayStats.orderCount,
                    totalRevenue: todayStats.totalRevenue,
                    totalProducts: todayStats.totalProducts
                },
                yesterday: {
                    orderCount: yesterdayStats.orderCount,
                    totalRevenue: yesterdayStats.totalRevenue,
                    totalProducts: yesterdayStats.totalProducts
                },
                changes: {
                    revenueChange: revenueChange.toFixed(2),
                    orderCountChange: orderCountChange.toFixed(2),
                    productCountChange: productCountChange.toFixed(2)
                }
            }
        });

    } catch (error) {
        res.status(500).json({
            status: "fail",
            message: "Error in getTodayStats controller",
            error: error.message
        });
    }
};


exports.getUsersCount = async (req, res) => {
    try {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const sevenDaysAgo = new Date(today);
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);

        const allUsers = await User.find().select("createdAt");

        const daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        const newUsersData = Array(7).fill(0);
        const totalUsersData = Array(7).fill(0);
        const labels = Array(7);
        const dateArray = [];

        for (let i = 0; i < 7; i++) {
            const date = new Date(today);
            date.setDate(date.getDate() - (6 - i));
            date.setHours(0, 0, 0, 0);
            labels[i] = daysOfWeek[date.getDay()];
            dateArray[i] = date;
        }

        allUsers.forEach(user => {
            const userDate = new Date(user.createdAt);
            userDate.setHours(0, 0, 0, 0);

            for (let i = 0; i < 7; i++) {
                if (userDate.getTime() === dateArray[i].getTime()) {
                    newUsersData[i]++;
                }
                if (userDate <= dateArray[i]) {
                    totalUsersData[i]++;
                }
            }
        });

        const totalNewUsers = newUsersData.reduce((acc, val) => acc + val, 0);

        res.status(200).json({
            status: "success",
            message: "Users count for last 7 days retrieved successfully",
            data: {
                newUsersData,
                totalUsersData,
                labels,
                totalNewUsers,
                currentTotalUsers: allUsers.length
            }
        });

    } catch (err) {
        res.status(500).json({
            status: "fail",
            message: "Error in getUsersCount controller",
            error: err.message
        });
    }
};


// exports.getTodaysOrders = async (req, res) => {
//     try {
//         // Get today's date at midnight
//         const today = new Date();
//         today.setHours(0, 0, 0, 0);

//         // Get yesterday's date at midnight
//         const yesterday = new Date(today);
//         yesterday.setDate(yesterday.getDate() - 1);

//         // Get today's orders
//         const todayOrders = await Transaction.find({
//             date: { $gte: today }
//         });

//         // Get yesterday's orders
//         const yesterdayOrders = await Transaction.find({
//             date: { $gte: yesterday, $lt: today }
//         });

//         // Calculate today's stats
//         const todayStats = {
//             orderCount: todayOrders.length,
//             totalProducts: todayOrders.reduce((acc, order) => {
//                 // Sum up quantities of all products in this order
//                 const orderTotal = order.products.reduce((sum, product) => {
//                     return sum + (product.quantity || 0);
//                 }, 0);
//                 return acc + orderTotal;
//             }, 0)
//         };

//         // Calculate yesterday's stats
//         const yesterdayStats = {
//             orderCount: yesterdayOrders.length,
//             totalProducts: yesterdayOrders.reduce((acc, order) => {
//                 // Sum up quantities of all products in this order
//                 const orderTotal = order.products.reduce((sum, product) => {
//                     return sum + (product.quantity || 0);
//                 }, 0);
//                 return acc + orderTotal;
//             }, 0)
//         };

//         // Calculate percentage changes
//         let orderCountChange = 0;
//         if (yesterdayStats.orderCount > 0) {
//             orderCountChange = ((todayStats.orderCount - yesterdayStats.orderCount) / yesterdayStats.orderCount) * 100;
//         } else if (todayStats.orderCount > 0) {
//             orderCountChange = 100;
//         }

//         let productCountChange = 0;
//         if (yesterdayStats.totalProducts > 0) {
//             productCountChange = ((todayStats.totalProducts - yesterdayStats.totalProducts) / yesterdayStats.totalProducts) * 100;
//         } else if (todayStats.totalProducts > 0) {
//             productCountChange = 100;
//         }

//         // Log the calculations for debugging
//         console.log('Today Orders:', todayOrders.map(order => ({
//             orderId: order._id,
//             products: order.products.map(p => p.quantity),
//             totalInOrder: order.products.reduce((sum, p) => sum + (p.quantity || 0), 0)
//         })));
//         console.log('Today Stats:', todayStats);
//         console.log('Yesterday Stats:', yesterdayStats);

//         res.status(200).json({
//             status: "success",
//             message: "Today's orders statistics retrieved successfully",
//             data: {
//                 today: {
//                     orderCount: todayStats.orderCount,
//                     totalProducts: todayStats.totalProducts
//                 },
//                 yesterday: {
//                     orderCount: yesterdayStats.orderCount,
//                     totalProducts: yesterdayStats.totalProducts
//                 },
//                 changes: {
//                     orderCountChange: orderCountChange.toFixed(2),
//                     productCountChange: productCountChange.toFixed(2)
//                 }
//             }
//         });

//     } catch (error) {
//         res.status(500).json({
//             status: "fail",
//             message: "Error in getTodaysOrders controller",
//             error: error.message
//         });
//     }
// }

exports.getProductsSoldCount = async (req, res) => {
    try {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const sevenDaysAgo = new Date(today);
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6); 

        const transactions = await Transaction.find({
            createdAt: { $gte: sevenDaysAgo }
        }).select("createdAt products");

        const daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        const chartData = Array(7).fill(0);
        const labels = Array(7);

        for (let i = 0; i < 7; i++) {
            const date = new Date(today);
            date.setDate(date.getDate() - (6 - i));
            labels[i] = daysOfWeek[date.getDay()];
        }

        transactions.forEach(transaction => {
            const transactionDate = new Date(transaction.createdAt);
            transactionDate.setHours(0, 0, 0, 0);

            const diffTime = transactionDate - sevenDaysAgo;
            const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

            if (diffDays >= 0 && diffDays < 7) {
                const totalProducts = transaction.products.reduce((sum, product) => {
                    return sum + (product.quantity || 0);
                }, 0);
                chartData[diffDays] += totalProducts;
            }
        });

        const totalProductsSold = chartData.reduce((sum, count) => sum + count, 0);

        res.status(200).json({
            status: "success",
            message: "Products sold count for last 7 days retrieved successfully",
            data: {
                chartData,
                labels,
                totalProductsSold
            }
        });

    } catch (err) {
        res.status(500).json({
            status: "fail",
            message: "Error in getProductsSoldCount controller",
            error: err.message
        });
    }
};


