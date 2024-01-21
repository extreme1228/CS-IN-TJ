#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "graphics_view_grid.h"
#include "subwaygraph.h"
#include "managelines.h"


#include <QMainWindow>
#include <QLabel>
#include <QGraphicsScene>
#include <QGraphicsView>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

public slots:
    //视图放大槽函数
    void on_toolEnlarge_triggered();
    //动作视图缩小槽函数
    void on_toolShrink_triggered();
    //动作添加所有槽函数
    void on_actionAddAll_triggered();
    //动作查看所有线路图槽函数
    void on_actionLineMap_triggered();
    //动作是否显示工具栏槽函数
    void on_actiontoolBar_triggered(bool checked);
    //动作关闭程序槽函数
    void on_actionClose_triggered();


    //添加列表视图部件变化槽函数
    void tabWidgetCurrentChanged(int index);
    //添加线路功能函数
    void addRoute();
    //添加站点功能函数
    void addStation();
    //添加连接功能函数
    void addConnection();
    //线路添加预览
    void routePreview();
    //站点添加预览
    void stationPreview();
    //连接添加预览
    void connectPreview();
    //更新换乘选择信息
    void updateTranserQueryInfo();

    void add_station_preview(QPointF add_coord);
//    //换乘出发线路改变槽函数
//    void transferStartLineChanged(QString lineName);
//    //换乘目的线路改变槽函数
//    void transferDstLineChanged(QString lineNames);
    //换乘查询槽函数
//    void transferQuery();


protected:
    Ui::MainWindow *ui;             //主窗口UI
    Graphics_View_Grid *myView;     //自定义视图，用于鼠标缩放
    QGraphicsScene *scene;          //场景
    SubwayGraph* subwayGraph;       //后端管理类
    ManageLines* manageLines;       //添加功能前端管理类

    //由线路表计算混合颜色
    QColor getLinesColor(const QList<int>& linesList);
    //获得线路表的名字集
    QString getLinesName(const QList<int>& linesList);
    //将站点的经纬度地理坐标转为视图坐标
    QPointF transferCoord(QPointF coord);
    //绘制网络图的边
    void drawEdges (const QList<Edge>& edgesList);
    //绘制网络图的站点节点
    void drawStations (const QList<int>& stationsList);

    void previewDrawEdges(const QList<Edge>& edgesList,int opt);

    void previewDrawStations(const QList<int>& stationsList,int opt);

private slots:
    void on_queryWayPushButton_clicked();

    void on_routeViewPushButton_clicked();

    void on_subwayAddPushButton_clicked();

private:
    //连接信号和槽函数
    void myConnect();
};

#define LINE_INFO_WIDTH 0   //预留边框用于信息展示
#define MARGIN 30           //视图左边距
#define NET_WIDTH 2000      //网络图最大宽度
#define NET_HEIGHT 2000     //网络图最大高度
#define SCENE_WIDTH (LINE_INFO_WIDTH+MARGIN*2+NET_WIDTH)    //视图宽度
#define SCENE_HEIGHT (MARGIN*2+NET_HEIGHT)                  //视图高度

#define EDGE_PEN_WIDTH 2    //线路边宽
#define NODE_HALF_WIDTH 3   //节点大小

#endif // MAINWINDOW_H
