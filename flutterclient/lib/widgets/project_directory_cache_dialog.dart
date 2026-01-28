import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/project_directory_index_provider.dart';
import '../services/window_service.dart';

class ProjectDirectoryCacheDialog extends StatelessWidget {
  const ProjectDirectoryCacheDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectDirectoryIndexProvider>();
    final isDesktop = WindowService().isDesktop;

    return AlertDialog(
      title: const Text('缓存管理'),
      content: SizedBox(
        width: 720,
        height: 420,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                const Expanded(child: Text('缓存保留时间（小时）')),
                SizedBox(
                  width: 120,
                  child: DropdownButton<int>(
                    value: provider.ttlHours,
                    isExpanded: true,
                    onChanged: (v) {
                      if (v != null) provider.setTtlHours(v);
                    },
                    items: const [1, 2, 4, 8, 12, 24]
                        .map(
                          (h) => DropdownMenuItem(
                            value: h,
                            child: Text('$h'),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isDesktop)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('桌面端监听目录变化并自动刷新'),
                value: provider.watchEnabledDesktop,
                onChanged: (v) => provider.setWatchEnabledDesktop(v),
              ),
            const Divider(height: 24),
            Expanded(
              child: provider.cacheInfos.isEmpty
                  ? const Center(child: Text('暂无缓存'))
                  : ListView.builder(
                      itemCount: provider.cacheInfos.length,
                      itemBuilder: (context, index) {
                        final info = provider.cacheInfos[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            info.root,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'entries=${info.entryCount}  building=${info.isBuilding}  watching=${info.isWatching}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              IconButton(
                                tooltip: '刷新',
                                icon: const Icon(Icons.refresh),
                                onPressed: info.isBuilding
                                    ? null
                                    : () => provider.refreshRoot(info.root),
                              ),
                              IconButton(
                                tooltip: '清理',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => provider.clearRoot(info.root),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
