#ifndef GRAPHICS_VIEW_ZOOM_H
#define GRAPHICS_VIEW_ZOOM_H

#include <QObject>
#include <QGraphicsView>

//定义Graphics_View_Grid类继承自QGraphicsView，实现鼠标拖动地图界面的移动和自由缩放的功能
class Graphics_View_Grid : public QObject {
  Q_OBJECT
public:
    Graphics_View_Grid(QGraphicsView* view);
  void gentle_grid(double factor);
  void set_modifiers(Qt::KeyboardModifiers modifiers);
  void set_zoom_factor_base(double value);

private:
  QGraphicsView* _view;
  Qt::KeyboardModifiers _modifiers;
  double _zoom_factor_base;
  QPointF target_scene_pos, target_viewport_pos;
  bool eventFilter(QObject* object, QEvent* event);

signals:
  void zoomed();
};

#endif // GRAPHICS_VIEW_ZOOM_H
