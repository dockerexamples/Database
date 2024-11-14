define get_env
$(shell grep -E '^$(1)=' template.env | cut -d '=' -f2)
endef

MONGO_INITDB_ROOT_USERNAME := $(call get_env,MONGO_INITDB_ROOT_USERNAME)
MONGO_INITDB_ROOT_PASSWORD := $(call get_env,MONGO_INITDB_ROOT_PASSWORD)
MONGO_DATABASE := $(call get_env,MONGO_DATABASE)

.PHONY: start_mongodb
start_mongodb:
	@echo "🚀 Running MongoDB"

	cd mongodb/mongo_without_replicas && \
	docker compose up -d

.PHONY: stop_mongodb
stop_mongodb:
	@echo "🚀 Stopping MongoDB"

	cd mongodb/mongo_without_replicas && \
	docker compose down

.PHONY: start_mongodb_replicas
start_mongodb_replicas:
	@echo "🚀 Running MongoDB replicas"

	cd mongodb/mongo_with_replicas && \
    docker compose up db0 db1 db2 --remove-orphans --build -d && \
    sleep 5
	docker exec -it db0 mongosh \
    -u ${MONGO_INITDB_ROOT_USERNAME} \
    -p ${MONGO_INITDB_ROOT_PASSWORD} \
    --eval 'rs.initiate({ \
        _id: "rs0", \
        members: [ \
            {_id: 0, host: "db0:27017", "priority": 3}, \
            {_id: 1, host: "db1:27017", "priority": 2}, \
            {_id: 2, host: "db2:27017", "priority": 1} \
        ] \
    });'
	#docker exec -it db0 mongosh -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} --eval 'db.getSiblingDB("${MONGO_DATABASE}").createUser({user: "${MONGO_INITDB_ROOT_USERNAME}", pwd: "${MONGO_INITDB_ROOT_PASSWORD}", roles: [{role: "readWrite", db: "${MONGO_DATABASE}"}]});'

.PHONY: stop_mongodb_replicas
stop_mongodb_replicas:
	@echo "🚀 Stopping MongoDB replicas"

	cd mongodb/mongo_with_replicas && \
	docker compose down