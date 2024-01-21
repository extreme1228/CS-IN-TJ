#ifndef SUBWAYGRAPH_H
#define SUBWAYGRAPH_H

#include "station.h"
#include "route.h"
#include <QString>
#include <QPoint>
#include <QVector>
#include <QHash>
#include<QMessageBox>

//图的邻接点结构,方便后续使用Dijstra算法进行快速求解
class NODE{
public:
    int stationID;      //邻接点ID
    double distance;    //两点距离

    //构造函数
    NODE(){};
    NODE(int s, double dist)
    {
        stationID = s;
        distance = dist;
    };

    //">"运算重载，用于小根堆
    friend bool operator > (const NODE&a,const NODE&b)
    {
        return a.distance > b.distance;
    }
};

//地铁视图网络类，集成staion和route，存储整个铁路网络的所有站点，线路信息，并在这个类中定义实现换乘路线求解函数
class SubwayGraph
{
protected:
    QVector<Station> stations;          //存储所有站点
    QVector<Route> routes;                //存储所有线路
    QHash<QString, int> stationsHash;   //站点名到存储位置的hash,方便staions访问
    QHash<QString, int> routesHash;      //线路名到存储位置的hash,方便routes访问
    QSet<Edge> edges;                   //所有边的集合
    QVector<QVector<NODE>> graph;       //地铁线路网络图
    QHash<Edge,QString>edgeName;        //判断该边属于哪条线路

public:
    //构造函数
    SubwayGraph();

    QString getEdgeName(Edge my_edge);
    //获取线路名
    QString getRouteName(int route_index);
    //获取线路颜色
    QColor getRouteColor(int route_index);
    //获取线路hash值
    int getRouteHash(QString routeName);
    //获取线路集合hash值
    QList<int> getRoutesHash(QList<QString> routesList);
    //获取线路名集合
    QList<QString> getRoutesNameList();
    //获取线路的所有包含站点
    QList<QString> getRouteStationsList(int route_index);
    //获取线路的站点连接关系
    QList<Edge>getRouteEdges(int route_index);

    //获取站点名
    QString getStationName(int s);
    //获取站点地理坐标
    QPointF getStationCoord(int s);
    //获取站点最小坐标
    QPointF getMinCoord();
    //获取站点最大坐标
    QPointF getMaxCoord();
    //获取站点所属线路信息
    QList<int> getStationRoutesInfo(int s);
    //获取两个站点的公共所属线路
    QList<int> getCommonLines(int s1, int s2);
    //获取站点hash值
    int getStationHash(QString stationName);
    //获取站点集合hash值
    QList<QString> getStationsNameList();

    //添加新线路
    void addRoute(QString lineName, QColor color);
    //添加新站点
    void addStation(Station s);
    //将旧站点添加到新线路上
    void addStationRoute(int station_index,int route_index);
    //将旧站点到新线路上删除
    void delStationRoute(int station_index,int route_index);
    //添加站点连接关系
    void addConnection(int s1, int s2, int l);
    //删去线路
    void delRoute(QString routeName);
    //删去站点
    void delStation(Station s);
//    //删去连接
    void delConnecttion(int s1,int s2,int l);

    //获取网络结构，用于前端显示
    void getGraph(QList<int>&stationsList, QList<Edge>&edgesList);
    //获取最少时间的线路
    bool queryTransferMinTime(int s1, int s2,
                              QList<int>&stationsList,
                              QList<Edge>&edgesList);
    //获取最少换乘的线路
    bool queryTransferMinTransfer(int s1, int s2,
                                  QList<int>&stationsList,
                                  QList<Edge>&edgesList,
                                  int&transfer_route);
    bool my_bfs(int s1, int s2,
                              QList<int>&stationsList,
                              QList<Edge>&edgesList);
    //从文件读取数据
    bool readFileData(QString fileName);

private:
    //清空数据
    void clearData();
    //插入一条边
    bool insertEdge(int s1, int s2);
    //更新边界经纬度
    void updateMinMaxLongiLati();
    //生成图结构
    void makeGraph();
};

#endif // SUBWAYGRAPH_H
