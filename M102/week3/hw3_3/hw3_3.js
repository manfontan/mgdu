conn = new Mongo();
db = conn.getDB("pcat");

db.products.createIndex({
    for: 1
});
var c = db.products.find({
    for: "ac3"
}).count();
print("number of ac3 products: ");
print(c);
var e = db.products.find({
    for: "ac3"
}).explain("executionStats");
print("Total docs examined:");
printjson(e.executionStats.totalDocsExamined);
