module.exports = (io) => {
    io.on('connection', (socket) => {
        console.log('Cart connected');

        socket.on("cart-location", (location) =>{
            console.log("📍Cart location in server", location);
            if(location.lat == 0 && location.lng == 0){
                return;
            } 
            io.emit("cart-location", location);
        })
        

        socket.on('disconnect', () => {
            console.log('Cart disconnected');
        });

    });
}