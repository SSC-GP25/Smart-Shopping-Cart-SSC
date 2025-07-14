import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_cart_app/core/services/map_consts.dart';
import 'package:smart_cart_app/core/themes/light_theme/app_colors_light.dart';
import 'package:smart_cart_app/features/home/presentation/manager/map_cubit/map_cubit.dart';
import 'package:smart_cart_app/features/home/presentation/manager/map_cubit/map_state.dart';
import 'package:smart_cart_app/features/home/presentation/views/widgets/custom_home_app_bar.dart';
import 'package:smart_cart_app/features/home/presentation/views/widgets/map_grid_painter.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  ui.Image? _userIcon;
  ui.Image? _productIcon;
  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
    _loadImages();
  }

  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<MapCubit>().searchProducts(query);
    });
  }

  Future<void> _loadImages() async {
    final userImage = await _loadImage("assets/images/user_location.png");
    final productImage = await _loadImage('assets/images/product_location.png');
    setState(() {
      _userIcon = userImage;
      _productIcon = productImage;
    });
  }

  Future<ui.Image> _loadImage(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userIcon == null || _productIcon == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: AppColorsLight.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<MapCubit, MapState>(
          listener: (context, state) {
            if (state.error.isNotEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const CustomHomeAppBar(title: "Find Your Way Easily"),
                    _buildSearchBar(context, state),
                    _buildMap(context, state),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, MapState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onTapOutside: (event) {
            _searchFocusNode.unfocus();
          },
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search for products...',
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: Colors.grey),
            prefixIcon: Icon(
              Icons.search,
              color: _isSearchFocused
                  ? AppColorsLight.primaryColor
                  : AppColorsLight.secondaryColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(
                color: AppColorsLight.secondaryColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(
                color: AppColorsLight.secondaryColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(
                color: AppColorsLight.primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColorsLight.scaffoldBackgroundColor,
          ),
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSearchResults(MapState state) {
    if (state.searchResults.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: state.searchResults.length,
        itemBuilder: (context, index) {
          final product = state.searchResults[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 0.95,
                child: CachedNetworkImage(
                  imageUrl: product.image ?? "",
                  errorWidget: (context, url, error) => SvgPicture.asset(
                    "assets/images/ImagePlaceholder.svg",
                    width: MediaQuery.sizeOf(context).width * 0.22,
                    fit: BoxFit.scaleDown,
                  ),
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            trailing: Text("${product.price} LE"),
            title: Text(product.title ?? "Product Name"),
            // subtitle: Text(product.aisle ?? "Aisle Name"),
            onTap: () {
              context.read<MapCubit>().selectProduct(product);
              context.read<MapCubit>().findPath();
              context.read<MapCubit>().clearSearchResults();
            },
          );
        },
      ),
    );
  }

  Widget _buildMap(BuildContext context, MapState state) {
    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
        context.read<MapCubit>().clearSearchResults();
      },
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 3.84,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: CustomPaint(
                  size: const Size(280, 440),
                  painter: GridPainter(
                    grid: grid,
                    geofences: geofences,
                    path: state.path,
                    userPosition: state.userPosition,
                    selectedProduct: state.selectedProduct,
                    userIcon: _userIcon!,
                    productIcon: _productIcon!,
                  ),
                ),
              ),
            ),

            // Rotated Labels (same as before)
            Positioned(
              bottom: 220,
              left: 0,
              child: Transform.rotate(
                angle: 90 * 3.1415926535 / 180,
                child: Text(
                  "Central Area",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: 20,
              child: Transform.rotate(
                angle: 90 * 3.1415926535 / 180,
                child: Text(
                  "Section A",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Colors.grey.shade400,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ),
            Positioned(
              bottom: 200,
              right: 55,
              child: Text(
                "Section B",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.grey.shade400,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            Positioned(
              bottom: 60,
              right: 55,
              child: Text(
                "Section C",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.grey.shade400,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),

            // Search Results Overlay (moved here)
            if (state.searchResults.isNotEmpty)
              Positioned(
                top: 0,
                left: 20,
                right: 20,
                child: Material(
                  elevation: 8,
                  color: Colors.transparent,
                  child: _buildSearchResults(state),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
