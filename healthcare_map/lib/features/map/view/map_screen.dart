import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';
import '../../dashboard/cubit/device_cubit.dart';
import '../../dashboard/cubit/device_state.dart';
import '../widgets/esp_marker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  void _showDeviceDetails(BuildContext context, device, LatLng phoneLatLng) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sensors, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(device.deviceId, style: AppTypography.heading),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(sheetContext),
                )
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text('📍 ${device.lat}°N, ${device.lng}°E', style: AppTypography.data),
            const SizedBox(height: 8),
            Text('⏱ Cập nhật: ${DateFormatter.formatTime(device.timestamp)}',
                style: AppTypography.body),
            const SizedBox(height: 8),
            Text('🔋 Pin: ${device.batteryPct}%  •  RSSI: ${device.rssi} dBm',
                style: AppTypography.body),
            const SizedBox(height: 8),
            Text('Chính xác GPS: ±${device.gpsAccuracy}m', style: AppTypography.body),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final espLatLng = LatLng(device.lat, device.lng);
                      // Đóng bottom sheet trước
                      Navigator.pop(sheetContext);
                      // Gọi API OSRM lấy tuyến đường
                      context.read<MapCubit>().getRoute(phoneLatLng, espLatLng);
                      // Tự động fit bản đồ để hiển thị cả 2 điểm
                      _fitBounds(phoneLatLng, espLatLng);
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Chỉ đường'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Tự động zoom/pan bản đồ sao cho cả 2 điểm đều hiển thị
  void _fitBounds(LatLng point1, LatLng point2) {
    final bounds = LatLngBounds.fromPoints([point1, point2]);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ'),
      ),
      body: BlocBuilder<MapCubit, MapState>(
        builder: (context, mapState) {
          return BlocBuilder<DeviceCubit, DeviceState>(
            builder: (context, deviceState) {
              final device = deviceState.deviceData;
              final espLatLng = device != null
                  ? LatLng(device.lat, device.lng)
                  : const LatLng(10.7769, 106.7009);

              return Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: espLatLng,
                      initialZoom: 15.0,
                      minZoom: 3.0,
                      maxZoom: 19.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: mapState.currentLayer == MapLayer.map
                            ? 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png'
                            : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                      ),
                      // Vẽ tuyến đường (Polyline) nếu có dữ liệu route
                      if (mapState.routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: mapState.routePoints,
                              strokeWidth: 5.0,
                              color: Colors.blue.shade700,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: mapState.phoneLatLng,
                            width: 30,
                            height: 30,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.mapPhone,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                          Marker(
                            point: espLatLng,
                            width: 60,
                            height: 60,
                            child: GestureDetector(
                              onTap: () {
                                if (device != null) {
                                  _showDeviceDetails(
                                      context, device, mapState.phoneLatLng);
                                }
                              },
                              child: const EspMarkerWidget(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Thanh chọn loại bản đồ
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: SegmentedButton<MapLayer>(
                      segments: const [
                        ButtonSegment(value: MapLayer.map, label: Text('Bản đồ')),
                        ButtonSegment(
                            value: MapLayer.satellite, label: Text('Vệ tinh')),
                      ],
                      selected: {mapState.currentLayer},
                      onSelectionChanged: (v) =>
                          context.read<MapCubit>().toggleLayer(v.first),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return AppColors.primary.withOpacity(0.2);
                          }
                          return Colors.white;
                        }),
                      ),
                    ),
                  ),

                  // Loading indicator khi đang tải tuyến đường
                  if (mapState.isLoadingRoute)
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 10),
                              Text('Đang tải tuyến đường...'),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Các nút điều hướng camera + nút Xóa đường
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nút Xóa đường - chỉ hiện khi có route
                        if (mapState.routePoints.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: FloatingActionButton.small(
                              heroTag: 'btn_clear_route',
                              backgroundColor: Colors.red.shade400,
                              tooltip: 'Xóa đường đi',
                              onPressed: () =>
                                  context.read<MapCubit>().clearRoute(),
                              child: const Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                        FloatingActionButton.small(
                          heroTag: 'btn_esp',
                          backgroundColor: AppColors.primary,
                          tooltip: 'Đến vị trí ESP32',
                          child: const Icon(Icons.my_location, color: Colors.white),
                          onPressed: () => _mapController.move(espLatLng, 16.0),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: 'btn_phone',
                          backgroundColor: AppColors.mapPhone,
                          tooltip: 'Đến vị trí điện thoại',
                          child: const Icon(Icons.smartphone, color: Colors.white),
                          onPressed: () =>
                              _mapController.move(mapState.phoneLatLng, 16.0),
                        ),
                      ],
                    ),
                  ),

                  // Card thông tin tọa độ ESP32
                  if (device != null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 72,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('📍 ESP32: ${device.lat}, ${device.lng}',
                                  style: AppTypography.data),
                              Text('Chính xác: ±${device.gpsAccuracy}m',
                                  style: AppTypography.caption),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
