#include "ui_mainwindow.h"
#include "ui_managelines.h"
#include "mainwindow.h"

#include <QGraphicsItem>
#include <QMessageBox>
#include <QColorDialog>
#include <QTimer>
#include <QDateTime>
#include <QFile>
#include <QTextStream>
#include <QDebug>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    //设置地铁线路图的鼠标键盘参数视图
    myView = new Graphics_View_Grid(ui->graphicsView);
    myView->set_modifiers(Qt::NoModifier);
    ui->graphicsView->setRenderHint(QPainter::Antialiasing);

    //设置场景,选择QGraphicsScene来最终绘制地铁线路图
    scene=new QGraphicsScene;
    scene->setSceneRect(-LINE_INFO_WIDTH,0,SCENE_WIDTH,SCENE_HEIGHT);//设置矩形参数
    ui->graphicsView->setScene(scene);//使用scene初始化UI界面的绘图
    ui->graphicsView->setDragMode(QGraphicsView::ScrollHandDrag);//设置为可拖拽模式


    //初始化自定义对象
    manageLines=new ManageLines(this);
    subwayGraph=new SubwayGraph;

    //一开始我们通过文件读入的方式初始化整个地铁线路,文件保证格式正确
    bool flag = subwayGraph->readFileData(":/data/data/outLine.txt");
    if (!flag)
    {
        QMessageBox box;
        box.setWindowTitle(tr("error information"));
        box.setIcon(QMessageBox::Warning);
        box.setText("读取数据错误!\n将无法展示内置线路,请检查文件夹中初始文件的格式是否正确！");
        box.addButton(tr("确定"), QMessageBox::AcceptRole);
        if (box.exec() == QMessageBox::Accepted)
        {
            box.close();
        }
    }

    myConnect();

    updateTranserQueryInfo();

    on_actionLineMap_triggered();
}

MainWindow::~MainWindow()
{
    delete ui;
    delete myView;
    delete scene;
    delete subwayGraph;
    delete manageLines;
}

////连接信号和槽函数
void MainWindow::myConnect()
{
    //动态添加界面的connect函数，用来初始化managelines的UI界面中的初始列表
    connect(manageLines->ui->tabWidget, SIGNAL(currentChanged(int)), this, SLOT(tabWidgetCurrentChanged(int)));
    connect(manageLines->ui->routeCommitPushButton, SIGNAL(clicked()), this, SLOT(addRoute()));
    connect(manageLines->ui->stationCommitPushButton, SIGNAL(clicked()), this, SLOT(addStation()));
    connect(manageLines->ui->connectCommitPushButton, SIGNAL(clicked()), this, SLOT(addConnection()));
    connect(manageLines->ui->routePreviewPushButton,SIGNAL(clicked()),this,SLOT(routePreview()));
    connect(manageLines->ui->stationPreviewPushButton,SIGNAL(clicked()),this,SLOT(stationPreview()));
    connect(manageLines->ui->connectPreviewPushButton,SIGNAL(clicked()),this,SLOT(connectPreview()));
//    connect(ui->addAction,SIGNAL(clicked()),this,SLOT(on_actionAddAll_triggered()));
}

//由线路表计算混合颜色
QColor MainWindow::getLinesColor(const QList<int>& linesList)
{
    QColor color1=QColor(255,255,255);
    QColor color2;
    for (int i=0; i<linesList.size(); ++i)
    {
        color2=subwayGraph->getRouteColor(linesList[i]);
        color1.setRed(color1.red()*color2.red()/255);
        color1.setGreen(color1.green()*color2.green()/255);
        color1.setBlue(color1.blue()*color2.blue()/255);
    }
    return color1;
}

//获得线路表的名字集
QString MainWindow::getLinesName(const QList<int>& linesList)
{
    QString str;
    str+="\t";
    for (int i=0; i<linesList.size(); ++i)
    {
        str+=" ";
        str+=subwayGraph->getRouteName(linesList[i]);
    }
//    qDebug()<<"tip="<<str<<"\n";
    return str;
}

//将站点的经纬度地理坐标转为视图坐标
QPointF MainWindow::transferCoord(QPointF coord)
{
    QPointF minCoord=subwayGraph->getMinCoord();//最小经纬度
    QPointF maxCoord=subwayGraph->getMaxCoord();//最大经纬度
    //等比例扩大后返回方便绘图
    double x = (coord.x()-minCoord.x())/(maxCoord.x()-minCoord.x())*NET_WIDTH+MARGIN;
    double y = (maxCoord.y()-coord.y())/(maxCoord.y()-minCoord.y())*NET_HEIGHT+MARGIN;
    return QPointF(x,y);
}

//绘制网络图的边
void MainWindow::drawEdges(const QList<Edge>& edgesList)
{
    for(int i=0; i<edgesList.size(); ++i)
    {
        int s1=edgesList[i].first;
        int s2=edgesList[i].second;

        QList<int> linesList=subwayGraph->getCommonLines(s1, s2);
        QColor color=getLinesColor(linesList);
        QString tip="途经： "+subwayGraph->getStationName(s1)+"--"+subwayGraph->getStationName(s2)+"\n线路：";
        tip+=getLinesName(linesList);
        QPointF s1Pos=transferCoord(subwayGraph->getStationCoord(s1));
        QPointF s2Pos=transferCoord(subwayGraph->getStationCoord(s2));

        QGraphicsLineItem* edgeItem=new QGraphicsLineItem;
        edgeItem->setPen(QPen(color, EDGE_PEN_WIDTH));
        edgeItem->setCursor(Qt::PointingHandCursor);
        edgeItem->setToolTip(tip);
        edgeItem->setPos(s1Pos);
        edgeItem->setLine(0, 0, s2Pos.x()-s1Pos.x(), s2Pos.y()-s1Pos.y());
        scene->addItem(edgeItem);
    }
}

//绘制网络图的站点节点
void MainWindow::drawStations (const QList<int>& stationsList)
{
    for (int i=0; i<stationsList.size(); ++i)
    {
        int s=stationsList[i];
        QString name=subwayGraph->getStationName(s);
        QList<int> linesList=subwayGraph->getStationRoutesInfo(s);
        QColor color=getLinesColor(linesList);
        QPointF longiLati=subwayGraph->getStationCoord(s);
        QPointF coord=transferCoord(longiLati);
        QString tip="站名：  "+name+"\n"+
                "经度：  "+QString::number(longiLati.x(),'f',7)+"\n"+
                "纬度：  "+QString::number(longiLati.y(),'f',7)+"\n"+
                "线路："+getLinesName(linesList);

        QGraphicsEllipseItem* stationItem=new QGraphicsEllipseItem;
        stationItem->setRect(-NODE_HALF_WIDTH, -NODE_HALF_WIDTH, NODE_HALF_WIDTH<<1, NODE_HALF_WIDTH<<1);
        stationItem->setPos(coord);
        stationItem->setPen(color);
        stationItem->setCursor(Qt::PointingHandCursor);
        stationItem->setToolTip(tip);

        if(linesList.size()<=1)
        {
            stationItem->setBrush(QColor(QRgb(0xffffff)));
        }

        scene->addItem(stationItem);

        QGraphicsTextItem* textItem=new QGraphicsTextItem;
        textItem->setPlainText(name);
        textItem->setFont(QFont("consolas",4,1));
        textItem->setPos(coord.x(),coord.y()-NODE_HALF_WIDTH*2);
        scene->addItem(textItem);
    }
}


//更新换乘选择信息
void MainWindow::updateTranserQueryInfo()
{
    //可能因为加入了新的线路或站点，所以我们需要重新更新换乘信息
    QComboBox* comboL = ui->subwayRouteComboBox;
    QComboBox* comboL1=ui->startStationComboBox;
    QComboBox* comboL2=ui->dstStationComboBox;

    comboL->clear();
    comboL1->clear();
    comboL2->clear();
    QList<QString>routesList = subwayGraph->getRoutesNameList();
    comboL->addItem("全部线路");
    for(auto &x:routesList){
        comboL->addItem(x);
    }
    QList<QString>stationsList = subwayGraph->getStationsNameList();
    for(auto &x:stationsList)
    {
        comboL1->addItem(x);
        comboL2->addItem(x);
    }
}

//添加列表视图部件变化槽函数
void MainWindow::tabWidgetCurrentChanged(int index)
{
    QWidget* widget=manageLines->ui->tabWidget->currentWidget();

    if(widget==manageLines->tabWigetsVector[1])
    {
        manageLines->ui->chooseRouteComboBox->clear();
        manageLines->ui->chooseRouteComboBox->addItems(subwayGraph->getRoutesNameList());
    }
    else if(widget==manageLines->tabWigetsVector[2])
    {
        manageLines->ui->station1ComboBox->clear();
        manageLines->ui->station2ComboBox->clear();
        manageLines->ui->connectRouteComboBox->clear();
        manageLines->ui->station1ComboBox->addItems(subwayGraph->getStationsNameList());
        manageLines->ui->station2ComboBox->addItems(subwayGraph->getStationsNameList());
        manageLines->ui->connectRouteComboBox->addItems(subwayGraph->getRoutesNameList());
    }
    Q_UNUSED(index);
}

//添加线路功能函数
void MainWindow::addRoute()
{
    QMessageBox box;
    box.setWindowTitle(tr("添加线路"));
    box.setWindowIcon(QIcon(":/icon/icon/subway.png"));

    if(manageLines->routeName.isEmpty())
    {
        //没有输入线路名称
        box.setIcon(QMessageBox::Warning);
        box.setText(tr("请输入线路名称！"));
    }
    else if(subwayGraph->getRouteHash(manageLines->routeName)==-1)
    {
        //输入的线路名称已经存在
        box.setIcon(QMessageBox::Information);
        box.setText(tr("线路：")+manageLines->routeName+tr(" 添加成功！"));
        subwayGraph->addRoute(manageLines->routeName, manageLines->routeColor);
        updateTranserQueryInfo();
    }
    else
    {
        box.setIcon(QMessageBox::Critical);
        box.setText(tr("添加失败！\n错误原因：线路名已存在！"));
    }

    box.addButton(tr("确定"),QMessageBox::AcceptRole);
    if(box.exec()==QMessageBox::Accepted)
    {
        box.close();
    }
    updateTranserQueryInfo();
}

//添加站点功能函数
void MainWindow::addStation()
{
    int station_index = subwayGraph->getStationHash(manageLines->stationName);
    int route_index = subwayGraph->getRouteHash(manageLines->station_of_routeName);
    if(manageLines->stationName.isEmpty())
    {
        QMessageBox::warning(this,"站点添加失败","请输入要添加的站点名称");
    }
    else if(manageLines->station_of_routeName.isEmpty())
    {
        QMessageBox::warning(this,"站点添加失败","请输入站点所属的线路名称");
    }
    else
    {
        QPointF station_coord;
        if(station_index!=-1)
        {
            //加入站点已存在，这时候我们视作想把原有的站点加入新的线路上，所以这时候站点的经纬度由程序内部传出
             QList<int> station_route_list = subwayGraph->getStationRoutesInfo(station_index);
             if(station_route_list.contains(route_index)){
                 QMessageBox::warning(this,"站点添加失败","所添加站点已位于所输入线路中。");
                 return;
             }
             else{
                 station_coord = subwayGraph->getStationCoord(station_index);
                 subwayGraph->addStationRoute(station_index,route_index);
                 station_coord += QPointF(-0.012,0.012);
                 station_coord = transferCoord(station_coord);
                 QMessageBox::information(this,"站点添加成功","所添加站点已成功加入线路。");
             }
        }
        else{
            //加入新站点
            station_coord = QPointF(manageLines->longitude, manageLines->latitude);
            QList<int>route_names;
            route_names.push_back(subwayGraph->getRouteHash(manageLines->station_of_routeName));
            Station s(manageLines->stationName, station_coord.rx(), station_coord.ry(),
                      route_names);
            subwayGraph->addStation(s);
            QMessageBox::information(this,"站点添加成功","所添加站点已成功加入线路。");
        }
    }
    updateTranserQueryInfo();
    on_actionLineMap_triggered();
}

//添加连接功能函数
void MainWindow::addConnection()
{
    QString station1=manageLines->ui->station1ComboBox->currentText();
    QString station2=manageLines->ui->station2ComboBox->currentText();
    int s1=subwayGraph->getStationHash(station1);
    int s2=subwayGraph->getStationHash(station2);
    int l=subwayGraph->getRouteHash(manageLines->ui->connectRouteComboBox->currentText());

    QMessageBox box;
    box.setWindowTitle(tr("添加连接"));
    box.setWindowIcon(QIcon(":/icon/icon/connect.png"));

    if(s1==-1||s2==-1||l==-1)
    {
        box.setIcon(QMessageBox::Warning);
        box.setText(tr("请选择已有的站点和线路！"));
    }
    else if(s1==s2)
    {
        box.setIcon(QMessageBox::Warning);
        box.setText(tr("同一站点不需要连接！"));
    }
    else if(!subwayGraph->getStationRoutesInfo(s1).contains(l))
    {
        box.setIcon(QMessageBox::Critical);
        box.setText(tr("连接失败！\n错误原因：所属线路不包含站点1"));
    }
    else if(!subwayGraph->getStationRoutesInfo(s2).contains(l))
    {
        box.setIcon(QMessageBox::Critical);
        box.setText(tr("连接失败！\n错误原因：所属线路不包含站点2"));
    }
    else
    {
        box.setIcon(QMessageBox::Information);
        box.setText(tr("添加连接成功！"));
        subwayGraph->addConnection(s1,s2,l);
    }
    if(box.exec()==QMessageBox::Accepted)
    {
        box.close();
    }
    updateTranserQueryInfo();
    on_actionLineMap_triggered();
}
//线路添加预览
void MainWindow::routePreview()
{
    if(manageLines->routeName.isEmpty()){
        QMessageBox::warning(this,"线路预览失败","请输入要添加的线路名称");
    }
    else{
        manageLines->route_scene->clear();
        QGraphicsLineItem* line=new QGraphicsLineItem;
        line->setPen(QPen(manageLines->routeColor, 5));
        line->setLine(50, 80, 100, 80);
        QGraphicsTextItem *text = new QGraphicsTextItem(manageLines->routeName);
        text->setFont(QFont("Arial", 12)); // 设置字体和大小
        text->setDefaultTextColor(manageLines->routeColor); // 设置文本颜色
        text->setPos(110, 65); // 设置文本位置
        manageLines->route_scene->addItem(line);
        manageLines->route_scene->addItem(text);
    }
}
//站点添加预览
void MainWindow::stationPreview()
{
    int station_index = subwayGraph->getStationHash(manageLines->stationName);
    int route_index = subwayGraph->getRouteHash(manageLines->station_of_routeName);
    if(manageLines->stationName.isEmpty())
    {
        QMessageBox::warning(this,"站点预览失败","请输入要添加的站点名称");
    }
    else if(manageLines->station_of_routeName.isEmpty())
    {
        QMessageBox::warning(this,"站点预览失败","请输入站点所属的线路名称");
    }
    else
    {
        QPointF station_coord;
        if(station_index!=-1)
        {
            //加入站点已存在，这时候我们视作想把原有的站点加入新的线路上，所以这时候站点的经纬度由程序内部传出
             QList<int> station_route_list = subwayGraph->getStationRoutesInfo(station_index);
             if(station_route_list.contains(route_index)){
                 QMessageBox::warning(this,"站点添加失败","所添加站点已位于所输入线路中。");
                 return;
             }
             else{
                 station_coord = subwayGraph->getStationCoord(station_index);
                 subwayGraph->addStationRoute(station_index,route_index);
                 station_coord += QPointF(-0.012,0.012);
                 station_coord = transferCoord(station_coord);
                 add_station_preview(station_coord);
                 subwayGraph->delStationRoute(station_index,route_index);
             }
        }
        else{
            //加入新站点
            station_coord = QPointF(manageLines->longitude, manageLines->latitude);
            QList<int>route_names;
            route_names.push_back(subwayGraph->getRouteHash(manageLines->station_of_routeName));
            Station s(manageLines->stationName, station_coord.rx(), station_coord.ry(),
                      route_names);
            subwayGraph->addStation(s);
            QPointF longiLati(manageLines->longitude - 0.012,manageLines->latitude + 0.012);
            QPointF add_coord=transferCoord(longiLati);
            add_station_preview(add_coord);
            subwayGraph->delStation(s);
        }
    }

}
void MainWindow::add_station_preview(QPointF add_coord)
{
    manageLines->station_scene->clear();
    QList<int> stationsList;
    QList<Edge> edgesList;
    subwayGraph->getGraph(stationsList,edgesList);
    previewDrawEdges(edgesList,2);
    previewDrawStations(stationsList,2);
    //我们对新加入的这个点标上红色的五角星表示预览的效果
    QPixmap pixmap(":/icon/icon/station.png"); // 替换为你的图像路径
    QGraphicsPixmapItem *pixmapItem = new QGraphicsPixmapItem(pixmap);
    // 设置图像项的位置
    pixmapItem->setPos(add_coord); // 指定坐标点
    // 将图像项添加到场景
    manageLines->station_scene->addItem(pixmapItem);
}
void MainWindow::previewDrawEdges(const QList<Edge> &edgesList,int opt)
{
    for(int i=0; i<edgesList.size(); ++i)
    {
        int s1=edgesList[i].first;
        int s2=edgesList[i].second;

        QList<int> linesList=subwayGraph->getCommonLines(s1, s2);
        QColor color=getLinesColor(linesList);
        QString tip="途经： "+subwayGraph->getStationName(s1)+"--"+subwayGraph->getStationName(s2)+"\n线路：";
        tip+=getLinesName(linesList);
        QPointF s1Pos=transferCoord(subwayGraph->getStationCoord(s1));
        QPointF s2Pos=transferCoord(subwayGraph->getStationCoord(s2));

        QGraphicsLineItem* edgeItem=new QGraphicsLineItem;
        edgeItem->setPen(QPen(color, EDGE_PEN_WIDTH));
        edgeItem->setCursor(Qt::PointingHandCursor);
        edgeItem->setToolTip(tip);
        edgeItem->setPos(s1Pos);
        edgeItem->setLine(0, 0, s2Pos.x()-s1Pos.x(), s2Pos.y()-s1Pos.y());
        if(opt == 2)manageLines->station_scene->addItem(edgeItem);
        else if(opt == 3)manageLines->connect_scene->addItem(edgeItem);
    }
}

void MainWindow::previewDrawStations(const QList<int> &stationsList,int opt)
{
    for (int i=0; i<stationsList.size(); ++i)
    {
        int s=stationsList[i];
        QString name=subwayGraph->getStationName(s);
        QList<int> linesList=subwayGraph->getStationRoutesInfo(s);
        QColor color=getLinesColor(linesList);
        QPointF longiLati=subwayGraph->getStationCoord(s);
        QPointF coord=transferCoord(longiLati);
        QString tip="站名：  "+name+"\n"+
                "经度：  "+QString::number(longiLati.x(),'f',7)+"\n"+
                "纬度：  "+QString::number(longiLati.y(),'f',7)+"\n"+
                "线路："+getLinesName(linesList);

        QGraphicsEllipseItem* stationItem=new QGraphicsEllipseItem;
        stationItem->setRect(-NODE_HALF_WIDTH, -NODE_HALF_WIDTH, NODE_HALF_WIDTH<<1, NODE_HALF_WIDTH<<1);
        stationItem->setPos(coord);
        stationItem->setPen(color);
        stationItem->setCursor(Qt::PointingHandCursor);
        stationItem->setToolTip(tip);

        if(linesList.size()<=1)
        {
            stationItem->setBrush(QColor(QRgb(0xffffff)));
        }

        if(opt == 2)manageLines->station_scene->addItem(stationItem);
        else if(opt == 3)manageLines->connect_scene->addItem(stationItem);
        QGraphicsTextItem* textItem=new QGraphicsTextItem;
        textItem->setPlainText(name);
        textItem->setFont(QFont("consolas",4,1));
        textItem->setPos(coord.x(),coord.y()-NODE_HALF_WIDTH*2);
        if(opt == 2)manageLines->station_scene->addItem(textItem);
        else if(opt == 3)manageLines->connect_scene->addItem(textItem);
    }
}
//连接添加预览
void MainWindow::connectPreview()
{
    QString station1=manageLines->ui->station1ComboBox->currentText();
    QString station2=manageLines->ui->station2ComboBox->currentText();
    int s1=subwayGraph->getStationHash(station1);
    int s2=subwayGraph->getStationHash(station2);
    int l=subwayGraph->getRouteHash(manageLines->ui->connectRouteComboBox->currentText());

    if(s1==-1||s2==-1||l==-1)
    {
       QMessageBox::warning(this,"连接预览失败","请选择已有的站点和线路");
    }
    else if(s1==s2)
    {
        QMessageBox::warning(this,"连接预览失败","同一站点不需要连接");
    }
    else if(!subwayGraph->getStationRoutesInfo(s1).contains(l))
    {
       QMessageBox::warning(this,"连接预览失败","所属线路不包含站点1");
    }
    else if(!subwayGraph->getStationRoutesInfo(s2).contains(l))
    {
       QMessageBox::warning(this,"连接预览失败","所属线路不包含站点2");
    }
    else
    {
        subwayGraph->addConnection(s1,s2,l);
        QPointF start_longiLati = subwayGraph->getStationCoord(s1);
        QPointF dst_longiLati = subwayGraph->getStationCoord(s2);
        start_longiLati+=QPointF(-0.012,0.012);
        dst_longiLati+=QPointF(-0.012,0.012);
        QPointF start_coord = transferCoord(start_longiLati);
        QPointF dst_coord = transferCoord(dst_longiLati);
        manageLines->connect_scene->clear();
        QList<int> stationsList;
        QList<Edge> edgesList;
        subwayGraph->getGraph(stationsList,edgesList);
        previewDrawEdges(edgesList,3);
        previewDrawStations(stationsList,3);
        //我们对新加入的这个点标上红色的五角星表示预览的效果
        QPixmap pixmap1(":/icon/icon/station.png"); // 替换为你的图像路径
        QGraphicsPixmapItem *pixmapItem1 = new QGraphicsPixmapItem(pixmap1);
        // 设置图像项的位置
        pixmapItem1->setPos(start_coord); // 指定坐标点
        // 将图像项添加到场景
        manageLines->connect_scene->addItem(pixmapItem1);
        QPixmap pixmap2(":/icon/icon/station.png"); // 替换为你的图像路径
        QGraphicsPixmapItem *pixmapItem2 = new QGraphicsPixmapItem(pixmap2);
        // 设置图像项的位置
        pixmapItem2->setPos(dst_coord); // 指定坐标点
        // 将图像项添加到场景
        manageLines->connect_scene->addItem(pixmapItem2);
        subwayGraph->delConnecttion(s1,s2,l);
    }
}

//视图放大槽函数
void MainWindow::on_toolEnlarge_triggered()
{
    ui->graphicsView->scale(1.5,1.5);
}

//动作视图缩小槽函数
void MainWindow::on_toolShrink_triggered()
{
    ui->graphicsView->scale(2.0/3,2.0/3);
}

//动作添加所有槽函数
void MainWindow::on_actionAddAll_triggered()
{
//    manageLines->setAllVisible();
    manageLines->show();
}


//动作查看所有线路图槽函数
void MainWindow::on_actionLineMap_triggered()
{
    scene->clear();
    QList<int> stationsList;
    QList<Edge> edgesList;
    subwayGraph->getGraph(stationsList,edgesList);
    drawEdges(edgesList);
    drawStations(stationsList);
//    qDebug()<<"stations.size()="<<stationsList.size()<<" edges.size()="<<edgesList.size();
}


//动作是否显示工具栏槽函数
void MainWindow::on_actiontoolBar_triggered(bool checked)
{
    if(checked)
    {
        ui->mainToolBar->show();
    }
    else
    {
        ui->mainToolBar->hide();
    }
}


//动作关闭程序槽函数
void MainWindow::on_actionClose_triggered()
{
    close();
}

void MainWindow::on_queryWayPushButton_clicked()
{
    int s1=subwayGraph->getStationHash(ui->startStationComboBox->currentText());
    int s2=subwayGraph->getStationHash(ui->dstStationComboBox->currentText());
    int way=ui->minDistanceRadioButton->isChecked()?1:2;

    if(s1==-1||s2==-1)
    {
        QMessageBox box;
        box.setWindowTitle(tr("换乘查询"));
        box.setWindowIcon(QIcon(":/icon/icon/query.png"));
        box.setIcon(QMessageBox::Warning);
        box.setText(tr("请选择有站点的线路"));
        box.addButton(tr("确定"),QMessageBox::AcceptRole);
        if(box.exec()==QMessageBox::Accepted)
        {
            box.close();
        }
    }
    else
    {
        QList<int> stationsList;
        QList<Edge> edgesList;
        int transfer_route = 0;
        bool flag=true;
        if(way==1)
        {
            flag=subwayGraph->queryTransferMinTime(s1, s2, stationsList, edgesList);
        }
        else
        {
            flag=subwayGraph->queryTransferMinTransfer(s1, s2, stationsList, edgesList,transfer_route);
        }

        if(flag)
        {
            scene->clear();
            drawEdges(edgesList);
            drawStations(stationsList);
            QString startStationName = subwayGraph->getStationName(s1);
            QString dstStationName = subwayGraph->getStationName(s2);
            QString text;
            if(way == 1){
                text = "以下线路路程最短，共换乘"+QString::number(stationsList.size()-1)+"个站点<br>";
            }
            else{
                text = "以下线路换乘最少，共换乘"+QString::number(transfer_route-1)+"条线路<br>";
            }
            text+="<h><b>"+startStationName + "(起点站) -> " + dstStationName + "(终点站)</b><h><br><br>";
            QString lst_route_name = "";
            for(int i=0; i<stationsList.size(); ++i)
            {
                QString line_text;
                QString stationName = subwayGraph->getStationName(stationsList[i]);
                if(i == stationsList.size() - 1){
                    line_text+="<br>&nbsp;&nbsp;&nbsp;↓<br>";
                    line_text += "<b>终点("+stationName+")</b>";
                }
                else if(i == 0){
                    line_text += "<b>起点("+stationName+")";
                    QString route_name_now = subwayGraph->getEdgeName(Edge(stationsList[i],stationsList[i+1]));
                    line_text +="  "+route_name_now + "</b>";
                    lst_route_name = route_name_now;
                }
                else
                {
                    line_text+="<br>&nbsp;&nbsp;&nbsp;↓<br>";
                    QString route_name_now = subwayGraph->getEdgeName(Edge(stationsList[i],stationsList[i+1]));
                    if(route_name_now!=lst_route_name){
                        line_text += "<b>"+stationName+" ";
                        line_text+=" 换乘";
                        line_text +=route_name_now + "</b>";
                    }
                    else{
                        line_text += stationName+" ";
                    }
                    lst_route_name = route_name_now;
                }
                text+=line_text;
            }
            QTextBrowser* browser=ui->transferRouteText;
            browser->clear();
            browser->setHtml(text);
        }
        else
        {
            QMessageBox box;
            box.setWindowTitle(tr("换乘查询"));
            box.setWindowIcon(QIcon(":/icon/icon/query.png"));
            box.setIcon(QMessageBox::Warning);
            box.setText(tr("您选择的起始和终止站点暂时无法到达！"));
            box.addButton(tr("确定"),QMessageBox::AcceptRole);
            if(box.exec()==QMessageBox::Accepted)
            {
                box.close();
            }
        }
    }
}

void MainWindow::on_routeViewPushButton_clicked()
{
    QString route_choose = ui->subwayRouteComboBox->currentText();
    if(route_choose == "全部线路"){
        on_actionLineMap_triggered();
    }
    else{
        int route_index = subwayGraph->getRouteHash(route_choose);
        if(route_index == -1){
            QMessageBox::warning(this,"线路显示失败","所选线路不存在,请重新选择！");
        }
        else{
            QList<QString>station_names = subwayGraph->getRouteStationsList(route_index);
            QList<Edge>edgesList;
            QList<int>stationsList;
            for(auto name : station_names){
//                qDebug()<<"name = "<<name<<'\n';
                int station_index = subwayGraph->getStationHash(name);
                if(station_index!=-1)stationsList.push_back(station_index);
            }
            edgesList = subwayGraph->getRouteEdges(route_index);
//            for(auto x:station_names){
//                qDebug()<<x<<" \n";
//            }
            scene->clear();
            drawEdges(edgesList);
            drawStations(stationsList);
        }
    }
}

void MainWindow::on_subwayAddPushButton_clicked()
{
    manageLines->show();
}
