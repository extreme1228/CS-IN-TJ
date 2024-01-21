#include "subwaygraph.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <queue>

//构造函数
SubwayGraph::SubwayGraph()
{

}

//从文件读取数据,主要负责初始化读入所有地铁站点信息
bool SubwayGraph::readFileData(QString fileName)
{
    QFile file(fileName);
    if(!file.open(QIODevice::ReadOnly))
        return false;
    QTextStream in(&file);
    while(!in.atEnd())
    {
        //因为初始地铁站点信息文件格式严格一致，所以在读文件的时候我们可以按照预定的文件格式去读取
        Route route;
        QString id, name, colour, fromTo, totalStations;
        QString color, froms, tos;
        bool ok;
        int total;
        Station station;
        int route_index, svIndex1 = -1, svIndex2 = -1;

        in>>id>>route.id;
        if(in.atEnd())break;
        in>>name>>route.name;
        in>>colour>>color;
        route.color.setRgba(color.remove(0,1).toUInt(&ok, 16));
        in>>fromTo>>froms>>tos;
        in>>totalStations>>total;

        route.startStaion = froms;
        route.dstStation = tos;
        if (routesHash.count(route.name))
        {
            route_index = routesHash[route.name];
            routes[route_index].startStaion = froms;
            routes[route_index].dstStation= tos;
        }
        else
        {
            route_index = routesHash[route.name] = routes.size();
            routes.push_back(route);
        }

        QString longlat;
        QStringList strList;
        for (int i=0; !in.atEnd()&&i<total; ++i)
        {
            in>>station.id>>station.name>>longlat;
            strList=longlat.split(QChar(','));
            station.longitude=strList.first().toDouble();
            station.latitude=strList.last().toDouble();
            if (stationsHash.count(station.name))
            {
                svIndex2 = stationsHash[station.name];
            }
            else
            {
                svIndex2 = stationsHash[station.name] = stations.size();
                stations.push_back(station);
            }

            stations[svIndex2].routesInfo.insert(route_index);
            routes[route_index].stationsSet.insert(svIndex2);
            if (i)
            {
                //svIndex1是上一个站点，svIndex2是当前站点，连接两个站点
                routes[route_index].edges.append(Edge(svIndex1, svIndex2));
                routes[route_index].edges.append(Edge(svIndex2, svIndex1));
                edgeName[Edge(svIndex1, svIndex2)] = routes[route_index].name;
                edgeName[Edge(svIndex2, svIndex1)] = routes[route_index].name;
                insertEdge(svIndex1, svIndex2);
            }
            svIndex1 = svIndex2;
        }

        bool flag = id=="id:" && name=="name:" && colour=="colour:" && fromTo=="fromTo:"
                && totalStations=="totalStations:" && ok && !in.atEnd();
//        qDebug()<< "ok="<<ok<<" flag="<<flag<<line.id<< " "<<station.name<< "\n";

        if(flag==false)
        {
            file.close();
            clearData();
            return false ;
        }
        in.readLine();
    }
    file.close();

    updateMinMaxLongiLati();

    return true;
}

//清空数据
void SubwayGraph::clearData()
{
    stations.clear();
    routes.clear();
    stationsHash.clear();
    routesHash.clear();
    edges.clear();
    graph.clear();
}

//插入一条边
bool SubwayGraph::insertEdge(int n1, int n2)
{
    if (edges.contains(Edge(n1, n2)) || edges.contains(Edge(n2, n1)))
    {
        return false;
    }
    edges.insert(Edge(n1, n2));
    return true;
}

//生成图结构
void SubwayGraph::makeGraph()
{
    graph.clear();
    graph=QVector<QVector<NODE>>(stations.size(), QVector<NODE>());
    for (auto &x : edges)
    {
        double dist=stations[x.first].distance(stations[x.second]);
        graph[x.first].push_back(NODE(x.second, dist));
        graph[x.second].push_back(NODE(x.first, dist));
    }
}


//获取线路颜色
QColor SubwayGraph::getRouteColor(int route_index)
{
    return routes[route_index].color;
}

//获取线路名
QString SubwayGraph::getRouteName(int route_index)
{
    return routes[route_index].name;
}

//获取线路hash值
int SubwayGraph::getRouteHash(QString routename)
{
    if(routesHash.contains(routename)){
        return routesHash[routename];
    }
    return -1;
}

//获取线路集合hash值
QList<int> SubwayGraph::getRoutesHash(QList<QString> routesList)
{
    QList<int> res_hashList;
    for (auto &x:routesList)
    {
        int ret_hash = getRouteHash(x);
        if(ret_hash == -1){
            res_hashList.clear();
            break;
        }
        res_hashList.push_back(ret_hash);
    }
    return res_hashList;
}

//获取线路名集合
QList<QString> SubwayGraph::getRoutesNameList()
{
    QList<QString> routesNameList;
    for (auto &x:routes)
    {
        routesNameList.push_back(x.name);
    }
    return routesNameList;
}

//获取线路的所有包含站点
QList<QString> SubwayGraph::getRouteStationsList(int route_index)
{
    QList<QString> stationsList;
    for (auto &x:routes[route_index].stationsSet)
    {
        stationsList.push_back(stations[x].name);
    }
    return stationsList;
}



//更新边界经纬度
void SubwayGraph::updateMinMaxLongiLati()
{
    double minLongitude=200, minLatitude=200;
    double maxLongitude=0, maxLatitude=0;

    for (auto &s : stations)
    {
        minLongitude = qMin(minLongitude, s.longitude);
        minLatitude = qMin(minLatitude, s.latitude);
        maxLongitude = qMax(maxLongitude, s.longitude);
        maxLatitude = qMax(maxLatitude, s.latitude);
    }
    Station::minLongitude = minLongitude;
    Station::minLatitude = minLatitude;
    Station::maxLongitude = maxLongitude;
    Station::maxLatitude = maxLatitude;

//    qDebug("minLon=%.10lf, minLat=%.10lf\n", minLongitude, minLatitude);
//    qDebug("maxLon=%.10lf, maxLat=%.10lf\n", maxLongitude, maxLatitude);
}

 //获取站点最小坐标
QPointF SubwayGraph::getMinCoord()
{
    return QPointF(Station::minLongitude, Station::minLatitude);
}

//获取站点最大坐标
QPointF SubwayGraph::getMaxCoord()
{
    return QPointF(Station::maxLongitude, Station::maxLatitude);
}

//获取两个站点的公共所属线路
QList<int> SubwayGraph::getCommonLines(int s1, int s2)
{
    QList<int> linesList;
    for (auto &tmp_route : stations[s1].routesInfo)
    {
        if(stations[s2].routesInfo.contains(tmp_route))
            linesList.push_back(tmp_route);
    }
    return linesList;
}

//获取站点名
QString SubwayGraph::getStationName(int s)
{
    return stations[s].name;
}

//获取站点地理坐标
QPointF SubwayGraph::getStationCoord(int s)
{
    return QPointF(stations[s].longitude, stations[s].latitude);
}

//获取站点所属线路信息
QList<int> SubwayGraph::getStationRoutesInfo(int s)
{
    return stations[s].routesInfo.values();
}

//获取站点hash值
int SubwayGraph::getStationHash(QString stationName)
{
    if(stationsHash.contains(stationName))
    {
        return stationsHash[stationName];
    }
    return -1;
}

//获取站点集合hash值
QList<QString> SubwayGraph::getStationsNameList()
{
    QList<QString> list;
    for (auto &a: stations)
    {
        list.push_back(a.name);
    }
    return list;
}



//添加新线路
void SubwayGraph::addRoute(QString lineName, QColor color)
{
    routesHash[lineName]=routes.size();
    routes.push_back(Route(lineName,color));
}

//添加新站点
void SubwayGraph::addStation(Station s)
{
    int hash=stations.size();
    stationsHash[s.name]=hash;
    stations.push_back(s);
    for (auto &a: s.routesInfo)
    {
        routes[a].stationsSet.insert(hash);
    }
    updateMinMaxLongiLati();
}

//将旧站点添加到新线路上
void SubwayGraph::addStationRoute(int station_index,int route_index)
{
    stations[station_index].routesInfo.insert(route_index);
    routes[route_index].stationsSet.insert(station_index);
}
void SubwayGraph::delStationRoute(int station_index,int route_index)
{
    stations[station_index].routesInfo.remove(route_index);
    routes[route_index].stationsSet.remove(station_index);
}
//添加站点连接关系
void SubwayGraph::addConnection(int s1, int s2, int l)
{
    insertEdge(s1,s2);
    routes[l].edges.append(Edge(s1,s2));
    routes[l].edges.append(Edge(s2,s1));
    edgeName[Edge(s1,s2)] = routes[l].name;
    edgeName[Edge(s2,s1)] = routes[l].name;
}
//删去线路
void SubwayGraph::delRoute(QString routeName)
{
    if(getRouteHash(routeName) == -1){
        //该线路不存在

    }
    else{

    }
}
//删去站点
void SubwayGraph::delStation(Station s)
{
    if(getStationHash(s.name) == -1){
        //站点不存在
    }
    else{
        int station_index = getStationHash(s.name);
        for(auto x:edges){
            if(x.first == station_index || x.second == station_index){
                edges.remove(x);
            }
        }
        for (auto it = stations.begin(); it != stations.end(); ++it) {
            if (it->name == s.name) {
                stations.erase(it); // 删除特定值的元素并返回下一个元素的迭代器
                break;
            }
        }
        stationsHash.remove(s.name);
    }
}
//删去连接
void SubwayGraph::delConnecttion(int s1, int s2, int l)
{
    if (edges.contains(Edge(s1, s2)))
    {
        edges.remove(Edge(s1, s2));
    }
    if(edges.contains(Edge(s2, s1))){
        edges.remove(Edge(s2,s1));
    }
    routes[l].edges.removeOne(Edge(s1,s2));
    routes[l].edges.removeOne(Edge(s2,s1));
    edgeName.remove(Edge(s1,s2));
    edgeName.remove(Edge(s2,s1));
    return ;
}
//获取网络结构，用于前端显示
void SubwayGraph::getGraph(QList<int>&stationsList, QList<Edge>&edgesList)
{
    stationsList.clear();
    for (int i=0; i<stations.size(); ++i)
    {
        stationsList.push_back(i);
    }
    edgesList=edges.values();
    return ;
}

//获取最少路程的线路
//核心是Disjstra
bool SubwayGraph::queryTransferMinTime(int start, int end, QList<int>&stationsList, QList<Edge>&edgesList)
{
    const double  INF  = 1e9+7;
    stationsList.clear();//用来存储最后解路径上的节点
    edgesList.clear();//存储最后解路径上的线路

    if(start == end)
    {
        stationsList.push_back(end);
        stationsList.push_back(start);
        return true;
    }
    makeGraph();

    std::vector<int> path(stations.size(), -1);//记录最短路径
    std::vector<double> dis(stations.size(), INF);//记其他点到起点的距离
    dis[start]=0;
    std::priority_queue<NODE, std::vector<NODE>, std::greater<NODE>> pq;//优先队列，按照距离起点的距离从大到小弹出
    pq.push(NODE(start, dis[start]));
    while(!pq.empty())
    {
        NODE top = pq.top();
        pq.pop();
        if(top.stationID==end)
        {
            break ;
        }

        for (int i=0; i<graph[top.stationID].size(); ++i)
        {
            NODE &adjNode=graph[top.stationID][i];
            if(top.distance+adjNode.distance<dis[adjNode.stationID])
            {
                //松弛操作
                path[adjNode.stationID]=top.stationID;
                dis[adjNode.stationID]=top.distance+adjNode.distance;
                pq.push(NODE(adjNode.stationID, dis[adjNode.stationID]));
            }
        }
    }

    if(path[end]==-1)
    {
        //两者之间不存在合法路径
        return false;
    }
    int p=end;
    while(path[p]!=-1)
    {
        stationsList.push_front(p);
        edgesList.push_front(Edge(path[p],p));
        p=path[p];
    }
    stationsList.push_front(start);

//    qDebug()<<"s1="<<s1<<" s2="<<s2<<" size= "<<stationsList.size()<<" "<<edgesList.size()<<"\n";
    return true;
}

//获取最少换乘的线路
//核心是bfs
bool SubwayGraph::queryTransferMinTransfer(int start, int end, QList<int>&stationsList, QList<Edge>&edgesList,int&transfer_route)
{
    stationsList.clear();
    edgesList.clear();
    transfer_route = 0;
    if(start == end)
    {
        stationsList.push_back(end);
        stationsList.push_back(start);
        return true;
    }
    makeGraph();
    std::vector<bool> routesVisted(routes.size(),false);
    std::vector<int> path(stations.size(),-1);
    path[start]=-2;
    std::queue<int> q;
    q.push(start);

    while(!q.empty())
    {
        int top=q.front();
        q.pop();
        for (auto &tmp_route: stations[top].routesInfo)
        {
            if(!routesVisted[tmp_route])
            {
                routesVisted[tmp_route]=true;
                for (auto &s: routes[tmp_route].stationsSet)
                {
                    if(path[s]==-1)
                    {
                        path[s]=top;
                        q.push(s);
                    }
                }
            }
        }
    }

    if(path[end]==-1)
    {
        return false;
    }
    int p=end;
    while(path[p]!=-2)
    {
        transfer_route++;
        QList<int>tmp_station;
        QList<Edge>tmp_edge;
//        qDebug()<<getStationName(p)<<" "<<getStationName(path[p])<<'\n';
        my_bfs(p,path[p],tmp_station,tmp_edge);
        for(auto x:tmp_station){
            stationsList.push_front(x);
        }
        stationsList.removeOne(path[p]);
        for(auto x:tmp_edge){
            edgesList.push_front(x);
        }
        p=path[p];
    }
    stationsList.push_front(start);
    return true;
}

bool SubwayGraph::my_bfs(int start, int end,QList<int>&stationsList,QList<Edge>&edgesList)
{
    int common_route;
    QSet<int>route_s1 = stations[start].routesInfo;
    QSet<int>route_s2 = stations[end].routesInfo;
    for(auto x:route_s1){
        if(route_s2.contains(x)){
            common_route = x;
            break;
        }
    }
    QString common_route_name = "";
    common_route_name = getRouteName(common_route);
    std::vector<int> path(stations.size(),-1);
    path[start]=-2;
    std::queue<int> q;
    q.push(start);
    while(!q.empty()){
        int top = q.front();
        q.pop();
        if(top == end)break;
        for(auto adjNode : graph[top]){
            if(path[adjNode.stationID]!=-1)continue;
            QString edgeName = getEdgeName(Edge(adjNode.stationID,top));
            if(edgeName!=common_route_name)continue;
            path[adjNode.stationID] = top;
            q.push(adjNode.stationID);
        }
    }
    if(path[end] == -1)return false;
    int p = end;
    while(path[p]!=-2){
        stationsList.push_front(p);
        edgesList.push_front(Edge(path[p],p));
        p = path[p];
    }
    stationsList.push_front(p);
    return true;
}
QList<Edge> SubwayGraph::getRouteEdges(int route_index)
{
    return routes[route_index].getRouteEdges();
}

QString SubwayGraph::getEdgeName(Edge my_edge)
{
    return edgeName[my_edge];
}
