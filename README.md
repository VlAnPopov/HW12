Вариант 2 - разрешить домену named_t манипулировать файлами в etc_t - как минимум, создавать файлы, как это предлагает audit2allow: "allow named_t etc_t:file create" в новом модуле. Однако это избыточно расширяет возможности named, снижая защищённость системы. 

Ещё более опасен вариант 3 - перевести named_t в режим permissive: semanage permissive -a named_t



