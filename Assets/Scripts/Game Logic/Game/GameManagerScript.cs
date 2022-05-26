using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class Settings
{
    [SerializeField]
    private ResolutionString resoution;

    [SerializeField]
    private bool m_fullScreen;

    [SerializeField]
    private float m_musicVolume;

    [SerializeField]
    private float m_sfxVolume;

    [SerializeField]
    private float m_sensitivity;

    public ResolutionString Resoution { get => resoution; set => resoution = value; }
    public bool FullScreen { get => m_fullScreen; set => m_fullScreen = value; }
    public float MusicVolume { get => m_musicVolume; set => m_musicVolume = value; }
    public float SfxVolume { get => m_sfxVolume; set => m_sfxVolume = value; }
    public float Sensitivity { get => m_sensitivity; set => m_sensitivity = value; }

    public Settings()
    {
        Resoution = new ResolutionString(1920, 1080);
        FullScreen = true;
        MusicVolume = 0.5f;
        SfxVolume = 0.5f;
        Sensitivity = 0.1f;
    }
}

public class GameManagerScript : MonoBehaviour
{
    public static GameManagerScript m_instance;

    [SerializeField]
    private Settings m_settings;

    List<IRestartGameElement> m_RestartGameElements;

    public Settings Settings { get => m_settings; set => m_settings = value; }

    private void Awake()
    {

        if(m_instance != null)
        {
            Destroy(gameObject);
        } else
        {
            m_instance = this;
            m_RestartGameElements = new List<IRestartGameElement>();
            m_settings = new Settings();
            DontDestroyOnLoad(gameObject);
        }
    }
    public void AddRestartGameElement(IRestartGameElement RestartGameElement)
    {
        m_RestartGameElements.Add(RestartGameElement);
    }
    public void DeleteRestartGameElement(IRestartGameElement RestartGameElement)
    {
        m_RestartGameElements.Remove(RestartGameElement);
    }

    public void RestartGame()
    {
        foreach (IRestartGameElement l_RestartGameElement in m_RestartGameElements)
            l_RestartGameElement.RestartGame();
    }
}

