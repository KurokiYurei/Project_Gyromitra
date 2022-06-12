using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

[System.Serializable]
public class ResolutionString
{
    public int m_width;
    public int m_height;

    public ResolutionString(int l_width, int l_height)
    {
        m_width = l_width;
        m_height = l_height;
    }
}

public class CanvasManager : MonoBehaviour
{
    [SerializeField]
    private GameManagerScript m_gameManager;

    [Header("Canvas")]
    [SerializeField]
    private GameObject m_startMenu;

    [SerializeField]
    private GameObject m_mainMenu;

    [SerializeField]
    private Button m_startGame;

    [SerializeField]
    private GameObject m_settingsMenu;

    private GameObject m_currentCanvas;

    [SerializeField]
    private Image m_mainTitle;

    [SerializeField]
    private Image m_mainBackground;

    [SerializeField]
    private Image m_settingsBackground;

    [SerializeField]
    private Image m_settingsFrame;

    [Header("Resolutions")]
    [SerializeField]
    private List<ResolutionString> resolutionList;

    [SerializeField]
    private int m_selectedResolution;

    [SerializeField]
    private Text m_textUiResolution;

    [SerializeField]
    private Toggle m_toggleFullScreen;

    [SerializeField]
    private bool m_fullScreen;

    [Header("Settings")]
    [SerializeField]
    private float m_musicVolume;

    [SerializeField]
    private float m_sfxVolume;

    [SerializeField]
    private float m_sensitivityMouse;

    [SerializeField]
    private float m_sensitivityController;

    [SerializeField]
    private Slider m_musicSlider;

    [SerializeField]
    private Slider m_sfxSlider;

    [SerializeField]
    private Slider m_sensitivityMouseSlider;

    [SerializeField]
    private Slider m_sensitivityControllerSlider;

    [SerializeField]
    private Text m_musicText;

    [SerializeField]
    private Text m_sfxText;

    [SerializeField]
    private Text m_sensitivityMouseText;

    [SerializeField]
    private Text m_sensitivityControllerText;

    [Header("Buttons")]
    [SerializeField]
    private Image[] m_buttonsImage;

    private void Awake()
    {

        // canvas

        ChangeCanvasToStartMenu();

        // resolution
        m_fullScreen = m_gameManager.Settings.FullScreen;

        m_selectedResolution = 0;

        m_toggleFullScreen.isOn = m_fullScreen;

        CreateResList();

        UpdateTextResolution();

        // settings

        m_musicVolume = m_gameManager.Settings.MusicVolume;
        m_sfxVolume = m_gameManager.Settings.SfxVolume;
        m_sensitivityMouse = m_gameManager.Settings.SensitivityMouse;
        m_sensitivityMouse = m_gameManager.Settings.SensitivityController;

        SetSettingsValues();

    }

    private void Update()
    {
        if (m_gameManager == null)
        {
            m_gameManager = GameObject.Find("GameManager").GetComponent<GameManagerScript>();
            m_startGame.onClick.AddListener(delegate { m_gameManager.LoadGame(); });
        }

        if (m_currentCanvas == m_startMenu && Input.anyKeyDown)
        {
            ChangeCanvasToMainMenu();
        }

    }

    private void DisableButtonImages()
    {
        foreach (Image image in m_buttonsImage)
        {
            image.gameObject.SetActive(false);
        }
    }

    /// <summary>
    /// Exit app
    /// </summary>
    public void ExitGame()
    {
        Application.Quit();
    }

    /// <summary>
    /// Change the canvas to Start Menu
    /// </summary>
    public void ChangeCanvasToStartMenu()
    {
        m_currentCanvas = m_startMenu;
        m_startMenu.SetActive(true);
        m_mainMenu.SetActive(false);
        m_settingsMenu.SetActive(false);
        m_mainTitle.gameObject.SetActive(true);
        m_settingsFrame.gameObject.SetActive(false);
        m_mainBackground.gameObject.SetActive(false);
        m_settingsBackground.gameObject.SetActive(false);
        DisableButtonImages();

        m_gameManager.OnChangeMenuPlaySound();
    }

    /// <summary>
    /// Change the canvas to Main Menu
    /// </summary>
    public void ChangeCanvasToMainMenu()
    {
        m_currentCanvas = m_mainMenu;
        m_mainMenu.SetActive(true);
        m_settingsMenu.SetActive(false);
        m_startMenu.SetActive(false);
        m_mainTitle.gameObject.SetActive(true);
        m_settingsFrame.gameObject.SetActive(false);
        m_mainBackground.gameObject.SetActive(true);
        m_settingsBackground.gameObject.SetActive(false);
        DisableButtonImages();

        m_gameManager.OnChangeMenuPlaySound();
    }

    /// <summary>
    /// Change the canvas to Settings Menu
    /// </summary>
    public void ChangeCanvasToSettingsMenu()
    {
        m_currentCanvas = m_settingsMenu;
        m_settingsMenu.SetActive(true);
        m_mainMenu.SetActive(false);
        m_startMenu.SetActive(false);
        m_mainTitle.gameObject.SetActive(false);
        m_settingsFrame.gameObject.SetActive(true);
        m_mainBackground.gameObject.SetActive(false);
        m_settingsBackground.gameObject.SetActive(true);
        UpdateValuesSettings();
        DisableButtonImages();

        m_gameManager.OnChangeMenuPlaySound();
    }

    /// <summary>
    /// Create a string list of all the avaliable resolutions
    /// </summary>
    private void CreateResList()
    {
        Resolution[] l_resolutionList = Screen.resolutions;

        List<ResolutionString> l_list = new List<ResolutionString>(l_resolutionList.Length);

        foreach (var res in l_resolutionList)
        {
            ResolutionString l_tempResString = new ResolutionString(res.width, res.height);

            l_list.Add(l_tempResString);

            if (Screen.width == l_tempResString.m_width && Screen.height == l_tempResString.m_height)
            {
                m_selectedResolution = l_list.Count - 1;

            }
        }

        resolutionList = l_list;
    }

    /// <summary>
    /// Updates the values saved in the game manager
    /// </summary>
    private void UpdateValuesSettings()
    {
        m_musicSlider.value = m_gameManager.Settings.MusicVolume;
        m_sfxSlider.value = m_gameManager.Settings.SfxVolume;
        m_sensitivityMouseSlider.value = m_gameManager.Settings.SensitivityMouse;
        m_sensitivityControllerSlider.value = m_gameManager.Settings.SensitivityController;
        m_toggleFullScreen.isOn = m_gameManager.Settings.FullScreen;
    }

    /// <summary>
    /// click left button res 
    /// </summary>
    public void LeftButtonResolution()
    {
        m_selectedResolution--;
        if (m_selectedResolution < 0) m_selectedResolution = 0;

        UpdateTextResolution();
    }

    /// <summary>
    /// click right button res 
    /// </summary>
    public void RightButtonResolution()
    {
        m_selectedResolution++;
        if (m_selectedResolution > resolutionList.Count - 1) m_selectedResolution = resolutionList.Count - 1;

        UpdateTextResolution();
    }

    /// <summary>
    /// update the text of the resolution panel 
    /// </summary>
    public void UpdateTextResolution()
    {
        m_textUiResolution.text = resolutionList[m_selectedResolution].m_width.ToString() + " x " + resolutionList[m_selectedResolution].m_height.ToString();
    }

    /// <summary>
    /// applyes the graphic changes
    /// </summary>
    public void ApplySettings()
    {
        // sounds
        m_gameManager.Settings.MusicVolume = m_musicSlider.value;
        m_gameManager.VCAMusic.setVolume(m_musicSlider.value);
        m_gameManager.Settings.SfxVolume = m_sfxSlider.value;
        m_gameManager.VCASFX.setVolume(m_sfxSlider.value);

        // sensitivity
        m_gameManager.Settings.SensitivityMouse = m_sensitivityMouseSlider.value;
        m_gameManager.Settings.SensitivityController = m_sensitivityControllerSlider.value;

        // fullscreen 
        m_gameManager.Settings.FullScreen = m_fullScreen;

        // resolution
        m_gameManager.Settings.Resoution = resolutionList[m_selectedResolution];

        // apply the values
        Screen.SetResolution(resolutionList[m_selectedResolution].m_width, resolutionList[m_selectedResolution].m_height, m_fullScreen);
    }

    /// <summary>
    /// toogle full screen change value script
    /// </summary>
    /// <param name="l_newVal"></param>
    public void ChangeToggleFullScreen(bool l_newVal)
    {
        m_fullScreen = l_newVal;
    }

    /// <summary>
    /// Set the starting values for the sliders in the setting
    /// </summary>
    private void SetSettingsValues()
    {
        m_musicSlider.value = m_musicVolume;
        m_sfxSlider.value = m_sfxVolume;
        m_sensitivityMouseSlider.value = m_sensitivityMouse;
        m_sensitivityControllerSlider.value = m_sensitivityController;
        UpdateTextSliders();
    }

    public void SetMusicVolume()
    {
        m_musicVolume = m_musicSlider.value;
        UpdateTextSliders();
    }

    public void SetSFXVolume()
    {
        m_sfxVolume = m_sfxSlider.value;
        UpdateTextSliders();
    }

    public void SetSensitivityMouse()
    {
        m_sensitivityMouse = m_sensitivityMouseSlider.value;
        UpdateTextSliders();
    }

    public void SetSensitivityController()
    {
        m_sensitivityController = m_sensitivityControllerSlider.value;
        UpdateTextSliders();
    }

    private void UpdateTextSliders()
    {
        m_musicText.text = m_musicSlider.value.ToString("0.0") + " db";
        m_sfxText.text = m_sfxSlider.value.ToString("0.0") + " db";
        m_sensitivityMouseText.text = m_sensitivityMouseSlider.value.ToString("0.0#");
        m_sensitivityControllerText.text = m_sensitivityControllerSlider.value.ToString("0.0#");
    }

}