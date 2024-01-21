#include "station.h"
#include <QtMath>

static double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double EarthRadius = 6371.0; // 地球半径，单位：千米

    // 将经纬度转换为弧度
    double dLat = qDegreesToRadians(lat2 - lat1);
    double dLon = qDegreesToRadians(lon2 - lon1);

    // Haversine公式计算距离
    double a = qSin(dLat / 2) * qSin(dLat / 2) +
               qCos(qDegreesToRadians(lat1)) * qCos(qDegreesToRadians(lat2)) *
               qSin(dLon / 2) * qSin(dLon / 2);

    double c = 2 * qAtan2(qSqrt(a), qSqrt(1 - a));

    double distance = EarthRadius * c; // 距离，单位：千米
    return distance;
}

double Station::minLongitude = 200;
double Station::minLatitude = 200;
double Station::maxLongitude = 0;
double Station::maxLatitude = 0;

//构造函数
Station::Station()
{

}

//构造函数
Station::Station(QString nameStr, double longi, double lati, QList<int> linesList)
{
    name = nameStr;
    longitude = longi;
    latitude = lati;
    routesInfo = QSet<int>(linesList.begin(),linesList.end());
}

//求取站点间实地直线距离
double Station::distance(Station other)
{
    return haversineDistance(latitude, longitude, other.latitude, other.longitude);
}
