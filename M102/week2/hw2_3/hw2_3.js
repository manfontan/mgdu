conn = new Mongo();
db = conn.getDB("pcat");

var p = db.products.find({
    "limits.voice": {
        $ne: null
    }
}).count();
print("Products with voice limit: " + p);
