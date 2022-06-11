using FMOD.Studio;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

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
    private float m_sensitivityMouse;

    [SerializeField]
    private float m_sensitivityController;

    public ResolutionString Resoution { get => resoution; set => resoution = value; }
    public bool FullScreen { get => m_fullScreen; set => m_fullScreen = value; }
    public float MusicVolume { get => m_musicVolume; set => m_musicVolume = value; }
    public float SfxVolume { get => m_sfxVolume; set => m_sfxVolume = value; }
    public float SensitivityMouse { get => m_sensitivityMouse; set => m_sensitivityMouse = value; }
    public float SensitivityController { get => m_sensitivityController; set => m_sensitivityController = value; }

    public Settings()
    {
        Resoution = new ResolutionString(1920, 1080);
        FullScreen = true;
        MusicVolume = 0.5f;
        SfxVolume = 0.5f;
        SensitivityMouse = 0.1f;
        SensitivityController = 0.8f;
    }
}

public enum Scenes
{
    Game = 0,
    Main_Menu = 1,
    Mapa = 2
}

public class GameManagerScript : MonoBehaviour
{
    public static GameManagerScript m_instance;

    [Header("FMOD")]
    public FMOD.Studio.VCA VCAMusic;
    public FMOD.Studio.VCA VCASFX;
    
    [Header("Loading Screen")]
    [SerializeField]
    private GameObject m_logo;

    [SerializeField]
    private GameObject m_background;    
    
    [SerializeField]
    private GameObject m_loadingScreenGame;

    [SerializeField]
    private List<AsyncOperation> m_scenesLoading = new List<AsyncOperation>();

    [Header("Settings")]
    [SerializeField]
    private Settings m_settings;

    private float m_secondsToWait;

    private float m_totalSceneProgress;

    List<IRestartGameElement> m_RestartGameElements;

    public Settings Settings { get => m_settings; set => m_settings = value; }

    private void Awake()
    {

        if (m_instance != null)
        {
            Destroy(gameObject);
        } else
        {
            m_instance = this;
            m_RestartGameElements = new List<IRestartGameElement>();
            m_settings = new Settings();
            LoadMainMenu();

            VCAMusic = FMODUnity.RuntimeManager.GetVCA("vca:/Music");
            VCASFX = FMODUnity.RuntimeManager.GetVCA("vca:/SFX");

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

    public void LoadMainMenu()
    {
        m_logo.SetActive(true);
        m_background.SetActive(true);

        m_scenesLoading.Add(SceneManager.LoadSceneAsync(((int)Scenes.Main_Menu), LoadSceneMode.Additive));

        m_secondsToWait = 2f;

        StartCoroutine(GetSceneLoadProgress());

    }

    public void LoadGame()
    {
        m_loadingScreenGame.SetActive(true);

        m_scenesLoading.Add(SceneManager.LoadSceneAsync(((int)Scenes.Mapa), LoadSceneMode.Additive));
        m_scenesLoading.Add(SceneManager.UnloadSceneAsync(((int)Scenes.Main_Menu)));

        m_secondsToWait = 5f;

        StartCoroutine(GetSceneLoadProgress());

    }

    public IEnumerator GetSceneLoadProgress()
    {
        for(int i = 0; i< m_scenesLoading.Count; i++)
        {
            while(!m_scenesLoading[i].isDone)
            {

                m_totalSceneProgress = 0;

                foreach(AsyncOperation l_operation in m_scenesLoading)
                {
                    m_totalSceneProgress += l_operation.progress;
                }

                m_totalSceneProgress = (m_totalSceneProgress / m_scenesLoading.Count) * 100;

                yield return null;
            }

            yield return new WaitForSeconds(m_secondsToWait);

            m_logo.SetActive(false);
            m_background.SetActive(false);
            m_loadingScreenGame.SetActive(false);

        }
     }
}

