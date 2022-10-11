from typing import Any, Type

from openpype.addons import BaseServerAddon

from .settings import FtrackSettings


class FtrackAddon(BaseServerAddon):
    name = "ftrack"
    title = "ftrack addon"
    version = "1.0.0"
    settings_model: Type[FtrackSettings] = FtrackSettings
    frontend_scopes: dict[str, Any] = {"project": {"sidebar": "hierarchy"}}
    services = {
        "leecher": {"image": "openpype/ay-ftrack-leecher:1.0.0"}
    }

    def setup(self):
        pass