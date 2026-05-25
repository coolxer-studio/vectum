package com.coolxer.model;

import com.coolxer.model.LuaFile;
import com.coolxer.model.dto.TaskDto;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Date;

/**
 * 推送任务实体类
 * <p>
 * 表示一个向量推送任务，包含任务的基本信息、配置和状态
 * </p>
 */
@Data
public class Task {

    private long id;
    /**
     * 任务名称
     */
    private String name;

    /**
     * 任务描述
     */
    private String description;

    /**
     * 配置信息
     */
    private String config;

    /**
     * 进程id
     */
    private int pid;

    private ArrayList<LuaFile> luaFiles;

    /**
     * 任务来源（插件来源标识为插件包名，插件类型的任务不允许编辑）
     */
    private String source = "default";

    private Date createTime;

    private Date updateTime;

    /**
     * 从DTO更新任务信息
     * @param taskDto 任务数据传输对象
     */
    public void updateFromDto(TaskDto taskDto) {
        this.name = taskDto.getName();
        this.description = taskDto.getDescription();
        this.config = taskDto.getConfig();
        this.source = taskDto.getSource();
        this.updateTime = java.sql.Timestamp.valueOf(LocalDateTime.now());
        if(createTime == null){
            createTime =  this.updateTime;
        }
    }

}