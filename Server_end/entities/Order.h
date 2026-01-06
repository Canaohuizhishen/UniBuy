#ifndef ORDER_H
#define ORDER_H

class Order {

private:
	String id;
	String orderNumber;
	String status;
	String trackingNo;
	String userId;
	String accountId;
	Decimal totalAmount;
	Date orderDate;
	String shippingAddress;
	String paymentMethod;

public:
	void getStatus();

	void setStatus(int status);

	void getOrderDetails();

	void updateTrackingInfo(int trackingNo);

	void validateOrder();

	void calculateTotal();

	void queryLogistics(int orderId);
};

#endif
