conn = new Mongo();
db = conn.getDB("pcat");

var p = db.products.findOne({
    "_id": ObjectId("507d95d5719dbef170f15c00")
});
print("Before Update");
printjson(p);
p.term_years = 3;
p.limits.sms.over_rate = 0.01;
db.products.update({
    "_id": ObjectId("507d95d5719dbef170f15c00")
}, p);
var result = db.products.find({
    "_id": ObjectId("507d95d5719dbef170f15c00")
}, {
    "_id": 0,
    term_years: 1,
    "limits.sms.over_rate": 1
});
print("After Update");
printjson(result.next());
/* Open a terminal and retur:

Manuels-MacBook-Pro:hw2_2 manuelfo$ mongo --shell pcat ../homework2.js
MongoDB shell version v3.4.1
connecting to: mongodb://127.0.0.1:27017/pcat
MongoDB server version: 3.4.1
type "help" for help
Server has startup warnings:
2017-02-08T11:02:25.745+0000 I CONTROL  [initandlisten]
2017-02-08T11:02:25.745+0000 I CONTROL  [initandlisten] ** WARNING: Access control is not enabled for the database.
2017-02-08T11:02:25.745+0000 I CONTROL  [initandlisten] **          Read and write access to data and configuration is unrestricted.
2017-02-08T11:02:25.745+0000 I CONTROL  [initandlisten]
> homework.b()
0.050.019031
*/
