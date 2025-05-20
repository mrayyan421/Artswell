enum TransactionType { card, bankTransfer, easyPaisaPayment, cashOnDelivery, }
enum TransactionStatus { pending, completed, failed, refunded, cancelled }

enum BodyFontSize{small,medium, large}
enum OrderStatus{toPay,toReceive,toBeShip,toBeDelivered,outForDelivery,delivered}
enum Payment{googlePay,raast,easyPaisa,payFast,cashOnDelivery,visa,masterCard,unionPay} //googlepay/visa/mastercard/unionpay to be looked into + Alfa payment gateway
enum Language{english,urdu}//google translate api to be looked into if if free
enum StoreCity{taxila,murree,faislabad} //look into geoLocation,google maps,Mapbox API, TBUF-> COD integration
enum CustomerFeedback{good,satisfactory,bad}


