#include "SortObject.h"

SortObject::SortObject(QObject *parent)
    : QObject(parent)
{

}

bool SortObject::getRunFlag() const
{
    return runFlag;
}

void SortObject::setRunFlag(bool flag)
{
    if (runFlag == flag) {
        return;
    }
    runFlag = flag;
    emit runFlagChanged(flag);//如果运行状态发生改变，那么发出相应信号
}
