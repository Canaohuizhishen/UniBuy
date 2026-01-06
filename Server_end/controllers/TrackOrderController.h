#ifndef TRACKORDERCONTROLLER_H
#define TRACKORDERCONTROLLER_H

class TrackOrderController {


public:
	void getUserOrders();

	void getLogisticsInfo(int orderId);

	void updateOrderStatus(int orderId, int status);

	void createServiceRequest(int orderId);

	void getHistoricalReviews(int userId);
};

#endif
