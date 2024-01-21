#include "graphics_view_grid.h"
#include <QMouseEvent>
#include <QApplication>
#include <QScrollBar>
#include <qmath.h>


//类的构造函数，实现初始值的赋值
Graphics_View_Grid::Graphics_View_Grid(QGraphicsView* view)
  : QObject(view), _view(view)
{
  _view->viewport()->installEventFilter(this);
  _view->setMouseTracking(true);//_view对象接受鼠标参数
  _modifiers = Qt::ControlModifier;
  _zoom_factor_base = 1.0015;//设置鼠标缩放因子
}

//使网格视图均匀缩放,确保缩放和移动操作的平稳过渡。
void Graphics_View_Grid::gentle_grid(double factor) {
  _view->scale(factor, factor);
  _view->centerOn(target_scene_pos);//保留缩放前鼠标位置作为缩放的中心位置，也就是以当前鼠标位置为中心缩放
  QPointF delta_viewport_pos = target_viewport_pos - QPointF(_view->viewport()->width() / 2.0,
                                                             _view->viewport()->height() / 2.0);
  QPointF viewport_center = _view->mapFromScene(target_scene_pos) - delta_viewport_pos;
  _view->centerOn(_view->mapToScene(viewport_center.toPoint()));
  emit zoomed();//发送视图变化信号
}

void Graphics_View_Grid::set_modifiers(Qt::KeyboardModifiers modifiers) {
  _modifiers = modifiers;

}

void Graphics_View_Grid::set_zoom_factor_base(double value) {
  _zoom_factor_base = value;
}

//事件过滤器
bool Graphics_View_Grid::eventFilter(QObject *object, QEvent *event) {
  if (event->type() == QEvent::MouseMove) {
      //鼠标移动操作
    QMouseEvent* mouse_event = static_cast<QMouseEvent*>(event);
    QPointF delta = target_viewport_pos - mouse_event->pos();
    if (qAbs(delta.x()) > 5 || qAbs(delta.y()) > 5) {
      target_viewport_pos = mouse_event->pos();
      target_scene_pos = _view->mapToScene(mouse_event->pos());
    }
  } else if (event->type() == QEvent::Wheel) {
      //鼠标滚轮操作
    QWheelEvent* wheel_event = static_cast<QWheelEvent*>(event);
    if (QApplication::keyboardModifiers() == _modifiers) {
      if (wheel_event->orientation() == Qt::Vertical) {
        double angle = wheel_event->angleDelta().y();
        double factor = qPow(_zoom_factor_base, angle);
        gentle_grid(factor);
        return true;
      }
    }
  }
  Q_UNUSED(object)
  return false;
}
