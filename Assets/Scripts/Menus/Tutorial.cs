using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using UnityEngine.Video;

public class Tutorial : MonoBehaviour
{
    [SerializeField]
    private Image m_image;

    [SerializeField]
    private bool m_playerIsInArea;

    [SerializeField]
    private Animation m_animation;

    [SerializeField]
    private PlayerInput m_playerInput;

    [SerializeField]
    private InputAction m_unpause;

    private void Awake()
    {
        m_playerInput = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerInput>();
        m_unpause = m_playerInput.actions["UnPause"];
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            ShowTutorial();
            other.GetComponent<CharacterControllerScript>().enabled = false;
            other.GetComponent<WeaponController>().enabled = false;
            m_playerIsInArea = true;
        }
    }

    private void Update()
    {

        print(m_unpause.triggered);

        if (m_playerIsInArea && m_unpause.triggered)
        {
            GameObject.FindGameObjectWithTag("Player").GetComponent<CharacterControllerScript>().enabled = true;
            GameObject.FindGameObjectWithTag("Player").GetComponent<WeaponController>().enabled = true;
            m_playerIsInArea = true;
            HideTutorial();
        }
    }

    public void ShowTutorial()
    {
        gameObject.SetActive(true);
        m_animation.Play("TutorialShow");
    }

    public void HideTutorial()
    {
        m_animation.Play("TutorialHide");
        gameObject.SetActive(false);
    }

}
