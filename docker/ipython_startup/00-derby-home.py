import os
import tempfile

_derby_home = tempfile.mkdtemp(prefix="derby_kernel_")

_existing = os.environ.get("PYSPARK_SUBMIT_ARGS", "pyspark-shell")
_shell_token = "pyspark-shell"

if _existing.strip().endswith(_shell_token):
    _prefix = _existing.strip()[: -len(_shell_token)].strip()
    os.environ["PYSPARK_SUBMIT_ARGS"] = (
        f'{_prefix} --conf "spark.driver.extraJavaOptions='
        f'-Dderby.system.home={_derby_home}" {_shell_token}'
    )
else:
    os.environ["PYSPARK_SUBMIT_ARGS"] = (
        f'--conf "spark.driver.extraJavaOptions='
        f'-Dderby.system.home={_derby_home}" {_existing}'
    )
