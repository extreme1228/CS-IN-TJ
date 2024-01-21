#include "ui_managelines.h"
#include "managelines.h"

#include <QPixmap>
#include <QColorDialog>
#include <QFile>
#include <QTextStream>
#include <QDebug>

//构造函数
ManageLines::ManageLines(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::ManageLines)
{
    ui->setupUi(this);
    tabWigetsVector.push_back(ui->tabAddLine);
    tabWigetsVector.push_back(ui->tabAddStation);
    tabWigetsVector.push_back(ui->tabAddConnection);

//    route_view = new Graphics_View_Grid(ui->routePreview);
//    route_view->set_modifiers(Qt::NoModifier);
//    ui->routePreview->setRenderHint(QPainter::Antialiasing);
    route_scene=new QGraphicsScene;
    route_scene->setSceneRect(0,0,200,160);//设置矩形参数
    ui->routePreview->setScene(route_scene);//使用scene初始化UI界面的绘图
//    ui->routePreview->setDragMode(QGraphicsView::ScrollHandDrag);//设置为可拖拽模式

    station_view = new Graphics_View_Grid(ui->stationPreview);
    station_view->set_modifiers(Qt::NoModifier);
    ui->stationPreview->setRenderHint(QPainter::Antialiasing);
    station_scene=new QGraphicsScene;
    station_scene->setSceneRect(0,0,2000,2000);//设置矩形参数
    ui->stationPreview->setScene(station_scene);//使用scene初始化UI界面的绘图
    ui->stationPreview->setDragMode(QGraphicsView::ScrollHandDrag);//设置为可拖拽模式

    connect_view = new Graphics_View_Grid(ui->connectPreview);
    connect_view->set_modifiers(Qt::NoModifier);
    ui->connectPreview->setRenderHint(QPainter::Antialiasing);
    connect_scene=new QGraphicsScene;
    connect_scene->setSceneRect(0,0,2000,2000);//设置矩形参数
    ui->connectPreview->setScene(connect_scene);//使用scene初始化UI界面的绘图
    ui->connectPreview->setDragMode(QGraphicsView::ScrollHandDrag);//设置为可拖拽模式
}

//析构函数
ManageLines::~ManageLines()
{
    delete ui;
}



//列表部件选择项改变
//void ManageLines::on_listWidget_itemClicked(QListWidgetItem *item)
//{
//    Q_UNUSED(item);
//    QString str;
//}

//点击选择颜色按钮
void ManageLines::on_chooseColorPushButton_clicked()
{
    QColorDialog colorDialog;
    colorDialog.setOptions(QColorDialog::ShowAlphaChannel);
    colorDialog.exec();
    routeColor=colorDialog.currentColor();
    return ;
}

void ManageLines::on_routeNameLineEdit_textChanged(const QString &arg1)
{
    routeName = arg1;//时刻将新增线路的名称赋值给routeName
}

void ManageLines::on_stationNameLineEdit_textChanged(const QString &arg1)
{
    stationName = arg1;
}

void ManageLines::on_longitudeSpinBox_valueChanged(double arg1)
{
    longitude = arg1;
}

void ManageLines::on_latitudeSpinBox_valueChanged(double arg1)
{
    latitude = arg1;
}

void ManageLines::on_chooseRouteComboBox_activated(const QString &arg1)
{
    station_of_routeName = arg1;
}


void ManageLines::on_station1ComboBox_activated(const QString &arg1)
{
    connectStation1Name = arg1;
}

void ManageLines::on_station2ComboBox_activated(const QString &arg1)
{
    connectStation2Name = arg1;
}

void ManageLines::on_connectRouteComboBox_activated(const QString &arg1)
{
    connectRouteName = arg1;
}
