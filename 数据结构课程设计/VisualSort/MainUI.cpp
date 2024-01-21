#include "MainUI.h"
#include "ui_MainUI.h"
#include "SortFactory.h"
#include "SortObject.h"
#include <QListView>

MainUI::MainUI(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainUI)
{
    //类的构造函数，实现初始化功能，主要是编写槽函数connect连接信号
    ui->setupUi(this);
    init();
}

MainUI::~MainUI()
{
    delete ui;
}

void MainUI::init()
{
    data_array.clear();
    //排序种类初始化
    ui->sortType->setView(new QListView(this));
    //排序类型
    ui->sortType->addItems(SortFactory::getInstance()->getSortList());
    //点击开始排序
    //开始排序按钮的connect函数，连接信号与槽

    //排序状态，排序时不能修改参数
    connect(ui->canvas, &MainCanvas::runFlagChanged,
            this, [this](bool running){
        ui->sortType->setEnabled(!running);
        ui->dataNum->setEnabled(!running);
        ui->opInterval->setEnabled(!running);
        ui->sortPushButton->setEnabled(!running);
        ui->inputOverPushButton->setEnabled(!running);
        ui->randomRadioButton->setEnabled(!running);
    });
}

void MainUI::on_inputOverPushButton_clicked()
{
    //点击完成输入后调用的函数。
    //输入完成按钮被按下，说明我们选择自行输入数据
    //当输入完成按钮按下后，我们自动忽略速记数据开关的状态，也即是自行输入数据的优先级要高于随机数据产生的优先级
    //读取输入框里的数据
    QString s = ui->inputLineEdit->text();
    QStringList t = s.split(" ");
    data_array.clear();
    for(auto x:t){
        int num = x.toInt();
        if(x == "0"){
            data_array.push_back(0);
        }
        else{
            if(num == 0){
                //返回值为0且本身输入的不是0，说明有非法字符
                QMessageBox::warning(this,"输入不合法提示","您输入的数组中含有非数字字符，请检查后重新输入！");
                ui->inputLineEdit->clear();//清空输入框
                data_array.clear();
                return;
            }
            else{
                data_array.push_back(num);
            }
        }
    }
}

void MainUI::on_randomRadioButton_clicked(bool checked)
{
    is_random_data = checked;
}

void MainUI::on_stopPushButton_clicked()
{
    //点击结束排序
    ui->inputLineEdit->clear();
    data_array.clear();
    ui->canvas->stop();
}

void MainUI::on_sortPushButton_clicked()
{
    //点击开始排序，首先检测合法状态
    if(data_array.size() == 0&&is_random_data == false){
        //既没有手动输入数据，也没有选择随机产生数据，那么弹出提示
        QMessageBox::warning(this,"提示","初始数据为空，请自行输入数据或是选择随机数据进行排序");
        return;
    }
    else if(data_array.size() == 0&&is_random_data == true){
        //这时，我们根据选择的数据个数来随机产生数据
        int num = ui->dataNum->value();
        for(int i=0;i<num;i++){
            data_array.push_back(QRandomGenerator::global()->bounded(-100,99));//这里我们不产生超过100的数据，防止可视化时视觉效果太差
        }
    }
    const int type = ui->sortType->currentIndex();//表示当前选择的排序类型
    if (type != ui->canvas->getSortType()) {
        //如果更换了排序类型，那么我们需要新建一个sortobject类来更新界面，进行新的排序
        SortObject *obj = SortFactory::getInstance()->createSortObject(type, ui->canvas);
        ui->canvas->setSortObject(type, obj);//设立新的sort类
    }
    //调用canvas类中的sort函数，进行排序
    ui->canvas->sort(data_array, ui->opInterval->value());
    ui->inputLineEdit->clear();
    data_array.clear();
}
