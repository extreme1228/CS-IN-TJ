#ifndef MANAGELINES_H
#define MANAGELINES_H

#include <QDialog>
#include <QVector>
#include <QTabWidget>
#include <QListWidget>
#include <QListWidgetItem>
#include <QIcon>
#include <QString>
#include<QGraphicsScene>
#include "graphics_view_grid.h"

class MainWindow;

namespace Ui {
class ManageLines;
}

class ManageLines : public QDialog
{
    Q_OBJECT

private slots:
//    void on_listWidget_itemClicked(QListWidgetItem *item);

    void on_chooseColorPushButton_clicked();

    void on_routeNameLineEdit_textChanged(const QString &arg1);

    void on_stationNameLineEdit_textChanged(const QString &arg1);

    void on_longitudeSpinBox_valueChanged(double arg1);

    void on_latitudeSpinBox_valueChanged(double arg1);

    void on_chooseRouteComboBox_activated(const QString &arg1);

    void on_station1ComboBox_activated(const QString &arg1);

    void on_station2ComboBox_activated(const QString &arg1);

    void on_connectRouteComboBox_activated(const QString &arg1);

public:
    //构造函数
    explicit ManageLines(QWidget *parent = 0);
    //析构函数
    ~ManageLines();

protected:
    Ui::ManageLines *ui;                //UI
     QVector<QWidget*> tabWigetsVector;  //保存tab部件指针
    QString routeName;                   //保存输入线路名
    QColor routeColor;                   //保存输入线路颜色
    QString stationName;                //保存输入站点名
    QString station_of_routeName;//输入站点的选择的对应的线路的名称
    QString connectStation1Name;
    QString connectStation2Name;
    QString connectRouteName;
    double longitude;                   //保存输入站点经度
    double latitude;                    //保存输入站点纬度
//    QList<QString> linesNameList;       //保存选择线路名表
//    QList<QString> linesSelected;       //保存选择的线路名
//    QList<QString> stationsNameList;    //保存选择站点名表

    Graphics_View_Grid* route_view;
    Graphics_View_Grid* station_view;
    Graphics_View_Grid* connect_view;
    //自定义场景变量，用来在添加栏的右侧显示预览功能。
    QGraphicsScene* route_scene;
    QGraphicsScene* station_scene;
    QGraphicsScene* connect_scene;
    //声明友元
    friend class MainWindow;
};

#endif // MANAGELINES_H
