const asyncHandler = require("express-async-handler");
const indoorMappingService = require("../services/indoorMappingService");
const logger = require("pino")();

// @desc    Find path between two points in the indoor map
// @route   POST /api/navigation/find-path
// @access  Public
exports.findPath = asyncHandler(async (req, res) => {
    const { start, end } = req.body;

    logger.info("Received pathfinding request", { start, end });

    // Validate input
    if (
        !start ||
        !end ||
        !Number.isInteger(start.x) ||
        !Number.isInteger(start.y) ||
        !Number.isInteger(end.x) ||
        !Number.isInteger(end.y)
    ) {
        logger.error("Invalid input coordinates", { start, end });
        return res.status(400).json({ error: "Invalid coordinates" });
    }

    // Check if start and end are within bounds
    if (
        start.x < 0 ||
        start.x >= indoorMappingService.GRID_WIDTH ||
        start.y < 0 ||
        start.y >= indoorMappingService.GRID_HEIGHT ||
        end.x < 0 ||
        end.x >= indoorMappingService.GRID_WIDTH ||
        end.y < 0 ||
        end.y >= indoorMappingService.GRID_HEIGHT
    ) {
        logger.error("Coordinates out of bounds", { start, end });
        return res.status(400).json({ error: "Coordinates out of bounds" });
    }

    // Check if start and end are walkable (using service method)
    if (!indoorMappingService.isValidMove(start.x, start.y) || !indoorMappingService.isValidMove(end.x, end.y)) {
        logger.error("Start or end position is not walkable", { start, end });
        return res.status(400).json({ error: "Start or end position is not walkable" });
    }

    try {
        logger.info(`Finding path from [${start.x}, ${start.y}] to [${end.x}, ${end.y}]`);
        const path = indoorMappingService.findPath(start, end);

        if (!path) {
            logger.error("No path found", { start, end });
            return res.status(404).json({ error: "No path found" });
        }

        logger.info("Path found successfully", { path });
        res.status(200).json({
            success: true,
            data: {
                path,
                steps: path.length - 1
            }
        });
    } catch (error) {
        logger.error("Error in pathfinding", { error: error.message });
        res.status(500).json({ error: "Internal server error" });
    }
});