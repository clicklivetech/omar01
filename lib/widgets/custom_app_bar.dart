import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showCart;
  final bool showSearch;
  final bool automaticallyImplyLeading;
  final VoidCallback? onCartPressed;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.showCart = true,
    this.showSearch = true,
    this.automaticallyImplyLeading = true,
    this.onCartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF6E58A8),
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white), 
      title: title != null ? Text(title!) : null,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        if (showSearch)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
        if (showCart)
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
                onPressed: onCartPressed ?? () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Consumer<AppState>(
                  builder: (context, appState, child) {
                    final cartItemCount = appState.totalCartItemsCount;
                    return cartItemCount > 0
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              cartItemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox();
                  },
                ),
              ),
            ],
          ),
        if (actions != null) ...actions!,
        const SizedBox(width: 16), 
      ],
      elevation: 0, 
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
