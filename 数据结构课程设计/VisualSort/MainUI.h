#pragma once
#include <QMainWindow>
#include<QVector>
#include<QMessageBox>
#include <QRandomGenerator>

namespace Ui {
class MainUI;
}

//主窗口
class MainUI : public QMainWindow
{
    Q_OBJECT
public:
    explicit MainUI(QWidget *parent = nullptr);
    ~MainUI();

private slots:
    void on_inputOverPushButton_clicked();

    void on_randomRadioButton_clicked(bool checked);

    void on_stopPushButton_clicked();

    void on_sortPushButton_clicked();

private:
    void init();

private:
    Ui::MainUI *ui;
    QVector<int>data_array;//表示要排序的数组内容，可能随机产生，也可能由输入决定
    bool is_random_data;//表示是否是随机产生的数据
};
