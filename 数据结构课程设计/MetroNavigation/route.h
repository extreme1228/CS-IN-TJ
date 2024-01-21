#ifndef LINE_H
#define LINE_H

#include <QString>
#include <QColor>
#include <QPair>
#include <QSet>
#include <QVector>

//定义边类型
typedef QPair<int,int> Edge;

class SubwayGraph;
class QTextStream;

//线路类
class Route
{
protected:
    int id;                     //线路ID
    QString name;               //线路名称
    QColor color;               //线路颜色
    QString startStaion,dstStation;  //线路起始站点
    QSet<int> stationsSet;      //线路站点集合,这里的站点是hash化后的的int型值
    QList<Edge> edges;           //线路站点连接关系
public:
    //构造函数
    Route(){};
    Route(QString lineName, QColor lineColor):name(lineName), color(lineColor)
    {};
    //获取具有先后顺序的站点连接关系
    QList<Edge>getRouteEdges()
    {
        return edges;
    }
    //声明友元
    friend class SubwayGraph;
    friend class QTextStream;
};

#endif // LINE_H
