# Local integration configurations

Keep robot-specific parameter overlays under:

```text
configs/<project-id>/
```

For a production robot, prefer a separate robot bringup repository that depends on these
upstream workspaces rather than editing upstream packages in place.
