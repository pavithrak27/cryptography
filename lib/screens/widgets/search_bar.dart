import 'package:crypto_mobile/constants/colors.dart';
import 'package:crypto_mobile/constants/font.dart';
import 'package:flutter/material.dart';

class CoinSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  const CoinSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  State<CoinSearchBar> createState() => _CoinSearchBarState();
}

class _CoinSearchBarState extends State<CoinSearchBar> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Rebuild to show/hide clear button
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.searchBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.searchBorder),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadowPrimary,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: AppColors.searchIcon,
              size: 21,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                onChanged: widget.onChanged,
                style: AppFonts.searchInput,
                cursorColor: AppColors.refreshSpinner,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search coin or symbol…',
                  hintStyle: AppFonts.searchHint,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
            if (widget.controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.onChanged('');
                  _focusNode.requestFocus();
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.searchIcon,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
