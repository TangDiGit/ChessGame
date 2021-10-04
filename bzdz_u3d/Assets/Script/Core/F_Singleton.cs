﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class F_Singleton<T> : MonoBehaviour where T : F_Singleton<T>
{

    private static T m_Instance = null;

    public static T instance
    {
        get
        {
            if (m_Instance == null)
            {
                m_Instance = GameObject.FindObjectOfType(typeof(T)) as T;
                if (m_Instance == null)
                {
                    m_Instance = new GameObject("Singleton of " + typeof(T).ToString(), typeof(T)).GetComponent<T>();
                    DontDestroyOnLoad(m_Instance);
                    m_Instance.Init();
                }

            }
            return m_Instance;
        }
    }

    private void Awake()
    {

        if (m_Instance == null)
        {
            m_Instance = this as T;
        }
    }
   

    public virtual void Init() { }


    private void OnApplicationQuit()
    {
        m_Instance = null;
    }
}